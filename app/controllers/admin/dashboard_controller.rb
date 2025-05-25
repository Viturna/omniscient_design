class Admin::DashboardController <  ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  before_action :authenticate_admin! 
  def index
    @current_page = 'dashboard'
    @users = User.all
  end

  def suivi_references
    @current_page = 'suivi_references'
    @suivis = Suivi.includes(:user).all
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def authenticate_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: "Accès interdit."
    end
  end
end
