class Admin::AdsController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  before_action :authenticate_admin!
  before_action :set_ad, only: %i[show edit update destroy approve reject]

  def index
    @current_page = 'ads'
    @ads = Ad.all.order(created_at: :desc)
  end

  def show; end

  def new
    @current_page = 'ads'
    @ad = Ad.new
  end

  def create
    @ad = Ad.new(ad_params)
    if @ad.save
      redirect_to admin_ads_path, notice: 'Publicité créée avec succès.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @ad.update(ad_params)
      redirect_to admin_ads_path, notice: 'Publicité mise à jour.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @ad.destroy
    redirect_to admin_ads_path, notice: 'Publicité supprimée.'
  end

  def approve
    start_date = @ad.start_date || Date.current
    end_date = if @ad.duration_days.present?
                 start_date + @ad.duration_days.days
               else
                 @ad.end_date
               end

    @ad.update(
      status: 'approved',
      active: true,
      start_date: start_date,
      end_date: end_date
    )
    redirect_to admin_ads_path, notice: 'Publicité validée ! Elle est désormais active.'
  end

  def reject
    reason = params[:rejection_reason].presence || params.dig(:ad, :rejection_reason).presence
    reason = reason.to_s.strip
    reason = "Visuel non conforme aux critères éditoriaux" if reason.blank?

    refund_message = ""

    # 1. Gestion du remboursement Stripe et résiliation de l'abonnement
    if @ad.stripe_subscription_id.present? || @ad.stripe_payment_intent_id.present?
      begin
        stripe_key = ENV['STRIPE_SECRET_KEY'].presence || Stripe.api_key.presence
        if stripe_key.present?
          Stripe.api_key = stripe_key

          # A. Annuler l'abonnement immédiatement
          if @ad.stripe_subscription_id.present?
            begin
              Stripe::Subscription.cancel(@ad.stripe_subscription_id)
            rescue StandardError => sub_err
              Rails.logger.warn("[Admin Ads Reject] Subscription cancel notice: #{sub_err.message}")
            end
          end

          # B. Rembourser le dernier paiement (PaymentIntent / Charge / Invoice)
          payment_intent_id = @ad.stripe_payment_intent_id

          if payment_intent_id.blank? && @ad.stripe_subscription_id.present?
            # Récupérer la dernière facture pour obtenir le charge / payment_intent
            invoices = Stripe::Invoice.list(subscription: @ad.stripe_subscription_id, limit: 1)
            last_invoice = invoices.data.first
            if last_invoice&.payment_intent.present?
              payment_intent_id = last_invoice.payment_intent
            elsif last_invoice&.charge.present?
              charge_id = last_invoice.charge
            end
          end

          if payment_intent_id.present?
            refund = Stripe::Refund.create(payment_intent: payment_intent_id, reason: 'requested_by_customer')
            @ad.stripe_payment_intent_id = payment_intent_id
            refund_message = " Remboursement Stripe de #{((refund.amount || @ad.price_paid.to_i) / 100.0).round(2)}€ effectué sans frais pour le client."
          elsif defined?(charge_id) && charge_id.present?
            refund = Stripe::Refund.create(charge: charge_id, reason: 'requested_by_customer')
            refund_message = " Remboursement Stripe de #{((refund.amount || @ad.price_paid.to_i) / 100.0).round(2)}€ effectué sans frais pour le client."
          end
        end
      rescue StandardError => e
        Rails.logger.error("[Admin Ads Reject] Stripe refund error: #{e.message}")
        refund_message = " (Attention : erreur lors du remboursement Stripe automatique : #{e.message})"
      end
    end

    @ad.update(
      status: 'rejected',
      active: false,
      rejection_reason: reason,
      subscription_status: 'canceled'
    )

    redirect_to admin_ads_path, notice: "Publicité refusée. Motif : « #{reason} ».#{refund_message}"
  end

  private

  def set_ad
    @ad = Ad.find(params[:id])
  end

  def ad_params
    params.require(:ad).permit(:title, :description, :link, :weight, :logged_out_only, :active, :start_date, :end_date, :image, :image_mobile)
  end

  def authenticate_admin!
    return if current_user&.admin?

    redirect_to root_path, alert: 'Accès interdit.'
  end
end
