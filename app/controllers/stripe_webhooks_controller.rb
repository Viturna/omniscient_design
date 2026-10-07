# frozen_string_literal: true

class StripeWebhooksController < ActionController::API
  def create
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET'] || Rails.application.credentials.dig(:stripe, :webhook_secret)

    stripe_key = ENV['STRIPE_SECRET_KEY'] || Rails.application.credentials.dig(:stripe, :secret_key) || ENV['STRIPE_API_KEY']
    Stripe.api_key = stripe_key if stripe_key.present?

    event = nil

    begin
      if endpoint_secret.present? && sig_header.present?
        event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
      else
        data = JSON.parse(payload, symbolize_names: true)
        event = Stripe::Event.construct_from(data)
      end
    rescue JSON::ParserError => e
      Rails.logger.error("[Stripe Webhook] Invalid payload: #{e.message}")
      return render json: { error: 'Invalid payload' }, status: :bad_request
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error("[Stripe Webhook] Invalid signature: #{e.message}")
      return render json: { error: 'Invalid signature' }, status: :bad_request
    rescue StandardError => e
      Rails.logger.error("[Stripe Webhook Error] #{e.message}")
      return render json: { error: e.message }, status: :bad_request
    end

    begin
      case event.type
      when 'invoice.paid'
        handle_invoice_paid(event.data.object)
      when 'payment_intent.succeeded'
        handle_payment_intent_succeeded(event.data.object)
      else
        Rails.logger.info("[Stripe Webhook] Unhandled event type: #{event.type}")
      end
    rescue StandardError => e
      Rails.logger.error("[Stripe Webhook Handler Error] #{e.message}\n#{e.backtrace.first(5).join("\n")}")
    end

    render json: { success: true }
  end

  private

  def handle_invoice_paid(invoice)
    return if invoice.amount_paid.to_i <= 0

    amount_paid = invoice.amount_paid # En centimes (ex: 20000 pour 200€)
    charge_id = invoice.charge

    split_payment(amount_paid, charge_id, "Facture #{invoice.id} - #{invoice.customer_email}")
  end

  def handle_payment_intent_succeeded(payment_intent)
    # Pour les paiements directs s'ils ne passent pas par une facture
    return if payment_intent.invoice.present? # Déjà géré par invoice.paid

    amount_paid = payment_intent.amount_received
    charge_id = payment_intent.latest_charge

    split_payment(amount_paid, charge_id, "Paiement #{payment_intent.id}")
  end

  def split_payment(total_amount, source_transaction, description)
    edgar_account = ENV['STRIPE_CONNECT_EDGAR_ID'].presence || ENV['STRIPE_CONNECT_ACCOUNT_ID'].presence
    thomas_account = ENV['STRIPE_CONNECT_THOMAS_ID'].presence

    Rails.logger.info("[Stripe Split] Début du split pour #{total_amount / 100.0}€ (Source: #{source_transaction || 'none'}) - Edgar: #{edgar_account} / Thomas: #{thomas_account}")

    # Calcul des parts
    edgar_percent = (ENV['STRIPE_CONNECT_EDGAR_PERCENT'].presence || 60.0).to_f / 100.0
    thomas_percent = (ENV['STRIPE_CONNECT_THOMAS_PERCENT'].presence || 40.0).to_f / 100.0

    # 1. Virement à Edgar (60%)
    if edgar_account.present?
      edgar_amount = (total_amount * edgar_percent).round
      begin
        transfer_params = {
          amount: edgar_amount,
          currency: 'eur',
          destination: edgar_account,
          description: "Part 60% Edgar - #{description}"
        }
        transfer_params[:source_transaction] = source_transaction if source_transaction.present?

        transfer = Stripe::Transfer.create(transfer_params)
        Rails.logger.info("[Stripe Split] Transfert réussi Edgar (#{edgar_amount / 100.0}€) : #{transfer.id}")
      rescue Stripe::InvalidRequestError => e
        # Si source_transaction n'est pas acceptée pour un abonnement ou charge non directe, réessayer sans source_transaction
        if source_transaction.present? && e.message.include?("source_transaction")
          begin
            transfer_params.delete(:source_transaction)
            transfer = Stripe::Transfer.create(transfer_params)
            Rails.logger.info("[Stripe Split Retry] Transfert réussi Edgar sans source_transaction (#{edgar_amount / 100.0}€) : #{transfer.id}")
          rescue StandardError => retry_err
            Rails.logger.error("[Stripe Split Retry Error Edgar] #{retry_err.message}")
          end
        else
          Rails.logger.error("[Stripe Split Error Edgar] #{e.message}")
        end
      rescue StandardError => e
        Rails.logger.error("[Stripe Split Error Edgar] #{e.message}")
      end
    end

    # 2. Virement à Thomas (40%)
    # Si le compte Stripe principal est déjà celui de Thomas, on ne transfère pas à soi-même (les fonds restants sont déjà sur le compte Thomas)
    if thomas_account.present? && !edgar_account.present?
      thomas_amount = (total_amount * thomas_percent).round
      begin
        transfer_params = {
          amount: thomas_amount,
          currency: 'eur',
          destination: thomas_account,
          description: "Part 40% Thomas - #{description}"
        }
        transfer_params[:source_transaction] = source_transaction if source_transaction.present?

        transfer = Stripe::Transfer.create(transfer_params)
        Rails.logger.info("[Stripe Split] Transfert réussi Thomas (#{thomas_amount / 100.0}€) : #{transfer.id}")
      rescue Stripe::InvalidRequestError => e
        if source_transaction.present? && e.message.include?("source_transaction")
          begin
            transfer_params.delete(:source_transaction)
            transfer = Stripe::Transfer.create(transfer_params)
            Rails.logger.info("[Stripe Split Retry] Transfert réussi Thomas sans source_transaction (#{thomas_amount / 100.0}€) : #{transfer.id}")
          rescue StandardError => retry_err
            Rails.logger.error("[Stripe Split Retry Error Thomas] #{retry_err.message}")
          end
        else
          Rails.logger.error("[Stripe Split Error Thomas] #{e.message}")
        end
      rescue StandardError => e
        Rails.logger.error("[Stripe Split Error Thomas] #{e.message}")
      end
    end
  end
end
