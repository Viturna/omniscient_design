class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:add_elements, :profil, :parrainage, :parrainage_filleul]
  before_action :check_certified, only: [:validation]
  before_action :check_admin_role, only: [:parrainage, :parrainage_filleul]
  def presentation
  end

  def add_elements
    @current_page = 'add_elements'
  end

  def users
  end

  def admin
  end

  def profil
    @current_page = 'profil'
    @user = current_user
  end
  def validation
    @current_page = 'profil'
    @oeuvres = Oeuvre.all.order(created_at: :desc)
    @designers = Designer.all.order(created_at: :desc)
    @studios = Studio.all.order(created_at: :desc)

    @oeuvres_count = Oeuvre.where(validation: true).count
    @designers_count = Designer.where(validation: true).count
    @studios_count = Studio.where(validation: true).count

    @oeuvres_count_val_false = Oeuvre.where(validation: false).count
    @designers_count_val_false = Designer.where(validation: false).count
    @studios_count_val_false = Studio.where(validation: false).count
  end
  def mentionslegales
  end
  def politiquedeconfidentialite
  end
  def cookies
  end
  
  def parrainage
    @current_page = 'profil'
    @user = current_user
    @referred_users = @user.referred_users
    @referred_count = @referred_users.count
  end
  def parrainage_filleul
    @user = current_user
  
    if request.post?
      referral_code = params[:referral_code]
  
      if referral_code.blank?
        flash[:error] = "Veuillez fournir un code de parrainage."
        redirect_to parrainage_filleul_path and return
      end
  
      referrer = User.find_by(referral_code: referral_code)
  
      if referrer
        if referrer == @user
          flash[:error] = "Vous ne pouvez pas être votre propre parrain."
        elsif Referral.exists?(referrer: referrer, referee: @user)
          flash[:notice] = "Vous êtes déjà lié à ce parrain."
        elsif @user.created_at < 30.days.ago
          flash[:error] = "Votre compte a plus de 30 jours. Vous ne pouvez pas utiliser un code de parrainage."
        else
          begin
            # Créer la relation de parrainage
            Rails.logger.debug "user: #{@user.inspect}"
            Referral.create!(referrer: referrer, referee: @user)
            flash[:success] = "Vous avez été lié à votre parrain : #{referrer.pseudo}."
          rescue ActiveRecord::RecordInvalid => e
            Rails.logger.debug "user: #{@user.inspect}"
            Rails.logger.error "Erreur lors de la création de la relation de parrainage : #{e.message}"
            flash[:error] = "Une erreur est survenue. Veuillez réessayer."
          end
        end
      else
        flash[:error] = "Code de parrainage invalide."
      end
  
      redirect_to parrainage_path
    end
  end
  
  def changelog
    @current_page = 'profil'
  end

  def secret_badge
  if user_signed_in?
    GamificationService.new(current_user).check_detail_finder
    redirect_to profil_path, notice: "Bravo ! Vous avez l'œil ! Badge débloqué."
  else
    redirect_to new_user_session_path, alert: "Connectez-vous pour débloquer ce secret."
  end
end

end
