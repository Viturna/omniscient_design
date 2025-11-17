class UsersController < ApplicationController
    layout 'admin', only: [:index]
  before_action :set_user, only: [:ban, :unban]
  before_action :check_admin_role, only: [:index, :certify, :uncertify, :admin_resend_confirmation, :ban, :unban]

  def index
    @current_page = 'users'
    
    # 1. Scope de base
    users_scope = User.includes(:etablissement, :daily_visits)

    # 2. Filtrage si recherche
    if params[:query].present?
      sql_query = <<~SQL
        users.firstname ILIKE :query OR
        users.lastname ILIKE :query OR
        users.email ILIKE :query OR
        users.pseudo ILIKE :query OR
        etablissements.name ILIKE :query
      SQL
      
      # On met à jour le scope avec le filtre
      users_scope = users_scope.left_outer_joins(:etablissement)
                               .where(sql_query, query: "%#{params[:query]}%")
    end

    all_users_scope = User.includes(:etablissement) 

    all_etablissements_stats = all_users_scope.joins(:etablissement)
                                            .group('etablissements.name')
                                            .count
                                            .sort_by { |_, c| -c } 
  @total_etablissements_count = all_etablissements_stats.length
  @stats_etablissements = Kaminari.paginate_array(all_etablissements_stats)
                                  .page(params[:etablissements_page])
                                  .per(10)

    @stats_source = all_users_scope.where.not(how_did_you_hear: [nil, '']).group(:how_did_you_hear).count.sort_by { |_, c| -c }
    @stats_status = all_users_scope.where.not(statut: [nil, '']).group(:statut).count.sort_by { |_, c| -c }
    @stats_certified_count = all_users_scope.where(certified: true).count
    @stats_banned_count = all_users_scope.where(banned: true).count

    # 4. Pagination et ordre final pour la table (sur le scope filtré)
    @users = users_scope.order(created_at: :asc)
                        .page(params[:page]).per(25)

    # 5. Données pour la carte (sur le total ou filtré, au choix. Ici filtré pour que la carte suive la recherche)
    @users_for_map = users_scope.where.not(etablissements: { latitude: nil, longitude: nil })
  end
  
  def visits
    @user = User.find(params[:id])
    @visits = @user.daily_visits.order(created_at: :desc).page(params[:page]).per(50)
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
