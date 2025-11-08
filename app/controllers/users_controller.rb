class UsersController < ApplicationController
    layout 'admin', only: [:index]
  before_action :set_user, only: [:ban, :unban]
  before_action :check_admin_role, only: [:index, :certify, :uncertify, :admin_resend_confirmation, :ban, :unban]

  def index
    @current_page = 'users'

    # 1. Requête de base (inclut :etablissement pour la table et les stats)
    users_scope = User.includes(:etablissement)

    # 2. Calcul des statistiques (efficace, via la BDD)
    @stats_etablissements = users_scope.joins(:etablissement)
                                      .group('etablissements.name')
                                      .count
                                      .sort_by { |_name, count| -count } # Tri par count desc

    @stats_source = users_scope.where.not(how_did_you_hear: [nil, ''])
                              .group(:how_did_you_hear)
                              .count
                              .sort_by { |_source, count| -count }

    @stats_status = users_scope.where.not(statut: [nil, ''])
                              .group(:statut)
                              .count
                              .sort_by { |_status, count| -count }

    @stats_certified_count = users_scope.where(certified: true).count
    @stats_banned_count = users_scope.where(banned: true).count

    # 3. Pagination pour la table (avec l'ordre)
    @users = users_scope.order(created_at: :asc)
                        .page(params[:page]).per(25)

    # 4. Données pour la carte (tous les users avec des coordonnées)
    @users_for_map = users_scope.where.not(etablissements: { latitude: nil, longitude: nil })
  end
  def ban
    if current_user.admin?
      @user.update(banned: true)
      redirect_to users_path, notice: I18n.t('user.banned_success', default: 'Utilisateur banni avec succès.')
    else
      redirect_to users_path, alert: I18n.t('user.access.denied_admin', default: "Vous n'avez pas les permissions nécessaires.")
    end
  end
  def unban
    if current_user.admin? && @user.banned?
      @user.update(banned: false)
      flash[:notice] = I18n.t('user.unbanned_success', default: "L'utilisateur a été débanni.")
    else
      flash[:alert] = I18n.t('user.unbanned_denied', default: "Vous ne pouvez pas débannir cet utilisateur.")
    end
    redirect_to users_path
  end

  def certify
    user = User.find(params[:id])
    if user.update(certified: true)
      flash[:notice] = I18n.t('user.certified_success', name: user.firstname, default: "#{user.firstname} a été certifié avec succès.")
    else
      flash[:alert] = I18n.t('user.certified_failure', default: "Une erreur est survenue lors de la certification.")
    end
    redirect_to users_path
  end

  def uncertify
    user = User.find(params[:id])
    if user.update(certified: false)
      flash[:notice] = I18n.t('user.uncertified_success', name: user.firstname, default: "La certification de #{user.firstname} a été retirée avec succès.")
    else
      flash[:alert] = I18n.t('user.uncertified_failure', default: "Une erreur est survenue lors du retrait de la certification.")
    end
    redirect_to users_path
  end

  def admin_resend_confirmation
  @user = User.find(params[:id])
  
  if @user.confirmed?
    redirect_to users_path, alert: "Cet utilisateur a déjà confirmé son compte."
  else
    token = @user.send(:generate_confirmation_token)
    @user.confirmation_sent_at = Time.now.utc
    @user.save(validate: false) 

    Devise::Mailer.confirmation_instructions(
      @user, 
      token, 
      { template_path: 'users/mailer', template_name: 'reconfirmation_instructions' }
    ).deliver_now
    
    redirect_to users_path, notice: "Mail de relance envoyé à #{@user.email}."
  end
end
  private

  

  def set_user
    @user = User.find(params[:id])
  end

end
