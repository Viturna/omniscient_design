class UsersController < ApplicationController
  before_action :set_user, only: [:ban,  :unban]
  def index
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

  private

  def set_user
    @user = User.find(params[:id])
  end
end
