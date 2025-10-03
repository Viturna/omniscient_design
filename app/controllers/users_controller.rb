class UsersController < ApplicationController
    layout 'admin', only: [:index]
  before_action :set_user, only: [:ban, :unban]
  before_action :check_admin_role, only: [:certify, :uncertify]
  def index
    @current_page = 'users'
    @users = User.all.order(:created_at)
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

  private

  def set_user
    @user = User.find(params[:id])
  end

end
