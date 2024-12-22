class UsersController < ApplicationController
  before_action :set_user, only: [:ban,  :unban]
  before_action :check_admin_role, only: [:certify, :uncertify]
  def index
    @current_page = 'profil'
    @users = User.all
  end
  def ban
    if current_user.admin?
      @user.update(banned: true)
      redirect_to users_path, notice: 'Utilisateur banni avec succès.'
    else
      redirect_to users_path, alert: 'Vous n\'avez pas les permissions nécessaires.'
    end
  end
  def unban
    if current_user.admin? && @user.banned?
      @user.update(banned: false)
      flash[:notice] = "L'utilisateur a été débanni."
    else
      flash[:alert] = "Vous ne pouvez pas débannir cet utilisateur."
    end
    redirect_to users_path
  end
  def certify
    user = User.find(params[:id])
    if user.update(certified: true)
      flash[:notice] = "#{user.firstname} a été certifié avec succès."
    else
      flash[:alert] = "Une erreur est survenue lors de la certification."
    end
    redirect_to users_path
  end

  def uncertify
    user = User.find(params[:id])
    if user.update(certified: false)
      flash[:notice] = "La certification de #{user.firstname} a été retirée avec succès."
    else
      flash[:alert] = "Une erreur est survenue lors du retrait de la certification."
    end
    redirect_to users_path
  end
  private

  def set_user
    @user = User.find(params[:id])
  end

end
