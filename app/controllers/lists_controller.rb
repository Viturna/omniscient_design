class ListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_list, only: [
    :show, :edit, :update, :destroy, :invite_editors,
    :change_role, :remove_user, :toggle_privacy,
    :remove_designer, :remove_oeuvre,
    :add_oeuvre, :add_designer
  ]
  
  def index
    @lists = current_user.lists
    @editor_lists = current_user.editable_lists
    @visitor_lists = current_user.visitor_lists
    @current_page = 'listes'
  end

  def show
    @current_page = 'listes'
    @countries = Country.where(id: DesignerCountry.select(:country_id).distinct)
    @notions = Notion.all

    # Designers
    selected_designer_ids = @list.designer_ids
    @selected_designers = Designer.where(id: selected_designer_ids, validation: true).order(:nom)
    @other_designers = Designer.where(validation: true)
                               .where.not(id: selected_designer_ids)
                               .order(:nom)
                               .page(params[:designers_page]).per(10)

    # Œuvres
    selected_oeuvre_ids = @list.oeuvre_ids
    @selected_oeuvres = Oeuvre.where(id: selected_oeuvre_ids, validation: true).order(:nom_oeuvre)
    @other_oeuvres = Oeuvre.where(validation: true)
                           .where.not(id: selected_oeuvre_ids)
                           .order(:nom_oeuvre)
                           .page(params[:oeuvres_page]).per(10)

    # Autorisation
    if @list.share_token.present? && @list.share_token == params[:share_token]
      render :show
    elsif @list.user == current_user || @list.editors.include?(current_user) || @list.visitors.include?(current_user)
      render :show
    else
      redirect_to root_path, alert: I18n.t('lists.access_denied')
    end
  end

  def shared
    @list = List.find_by(share_token: params[:share_token])
    if @list
      # Designers
      selected_designer_ids = @list.designer_ids
      @selected_designers = Designer.where(id: selected_designer_ids, validation: true).order(:nom)
      @other_designers = Designer.where(validation: true)
                                 .where.not(id: selected_designer_ids)
                                 .order(:nom)
                                 .page(params[:designers_page]).per(10)

      # Œuvres
      selected_oeuvre_ids = @list.oeuvre_ids
      @selected_oeuvres = Oeuvre.where(id: selected_oeuvre_ids, validation: true).order(:nom_oeuvre)
      @other_oeuvres = Oeuvre.where(validation: true)
                             .where.not(id: selected_oeuvre_ids)
                             .order(:nom_oeuvre)
                             .page(params[:oeuvres_page]).per(10)

      render :show
    else
      redirect_to root_path, alert: I18n.t('lists.access_denied')
    end
  end

  def new
    @current_page = 'listes'
    @list = current_user.lists.build

    # convertir en tableau
    @oeuvres   = Oeuvre.where(validation: true).order(:nom_oeuvre).limit(10).to_a
    @designers = Designer.where(validation: true).order(:nom).limit(10).to_a
    @domaines  = Domaine.all

    # --- PRE-SELECTION oeuvre ---
    if params[:oeuvre_id].present?
      selected_oeuvre = Oeuvre.find_by(id: params[:oeuvre_id], validation: true)
      if selected_oeuvre
        @oeuvres.unshift(selected_oeuvre) unless @oeuvres.include?(selected_oeuvre)
        @selected_oeuvre_ids = [selected_oeuvre.id]
      end
    end

    # --- PRE-SELECTION designer ---
    if params[:designer_id].present?
      selected_designer = Designer.find_by(id: params[:designer_id], validation: true)
      if selected_designer
        @designers.unshift(selected_designer) unless @designers.include?(selected_designer)
        @selected_designer_ids = [selected_designer.id]
      end
    end

    
  end



  def create
    @list = current_user.lists.build(list_params)

    if @list.save
      if params[:designer_ids].present?
        designer_ids = params[:designer_ids].split(',').map(&:to_i)
        @list.designers = Designer.where(id: designer_ids)
      end

      if params[:oeuvre_ids].present?
        oeuvre_ids = params[:oeuvre_ids].split(',').map(&:to_i)
        @list.oeuvres = Oeuvre.where(id: oeuvre_ids)
      end

      redirect_to @list, notice: I18n.t('lists.create.success')
    else
      @oeuvres = Oeuvre.where(validation: true).order(:nom_oeuvre).limit(10)
      @designers = Designer.where(validation: true).order(:nom).limit(10)
      @domaines = Domaine.all

      @selected_designer_ids = params[:designer_ids].to_s.split(',').map(&:to_i)
      @selected_oeuvre_ids = params[:oeuvre_ids].to_s.split(',').map(&:to_i)

      render :new
    end
  end

  def edit
    @current_page = 'listes'
  end

  def update
    if @list.update(list_params)
      redirect_to @list, notice: I18n.t('lists.update.success')
    else
      render :edit
    end
  end

  def destroy
    @list.destroy
    redirect_to lists_url, notice: I18n.t('lists.destroy.success')
  end

  def remove_designer
    designer = Designer.find(params[:designer_id])
    notice = if @list.designers.delete(designer)
               I18n.t('lists.remove.designer.success')
             else
               I18n.t('lists.remove.designer.failure')
             end
    redirect_to request.referer, notice: notice
  end

  def remove_oeuvre
    oeuvre = Oeuvre.find(params[:oeuvre_id])
    notice = if @list.oeuvres.delete(oeuvre)
               I18n.t('lists.remove.oeuvre.success')
             else
               I18n.t('lists.remove.oeuvre.failure')
             end
    redirect_to request.referer, notice: notice
  end

  def add_oeuvre
    oeuvre = Oeuvre.find(params[:oeuvre_id])
    if @list.oeuvres.include?(oeuvre)
      redirect_to request.referer, alert: I18n.t('lists.add.oeuvre.exists')
    else
      if @list.oeuvres << oeuvre
        redirect_to request.referer, notice: I18n.t('lists.add.oeuvre.success')
      else
        redirect_to request.referer, alert: I18n.t('lists.add.oeuvre.failure')
      end
    end
  end

  def add_designer
    designer = Designer.find(params[:designer_id])
    if @list.designers.include?(designer)
      redirect_to request.referer, alert: I18n.t('lists.add.designer.exists')
    else
      if @list.designers << designer
        redirect_to request.referer, notice: I18n.t('lists.add.designer.success')
      else
        redirect_to request.referer, alert: I18n.t('lists.add.designer.failure')
      end
    end
  end

  def toggle_privacy
    if params[:privacy] == 'public'
      @list.update(share_token: @list.previous_share_token || SecureRandom.hex(10))
      notice = I18n.t('lists.privacy.public')
    else
      @list.update(previous_share_token: @list.share_token, share_token: nil)
      notice = I18n.t('lists.privacy.private')
    end
    redirect_to @list, notice: notice
  end

  def invite_editors
    invited_user = User.find_by(email: params[:email])
    role         = params[:role]

    if invited_user
      if role == 'editor'
        @list.editors << invited_user unless @list.editors.include?(invited_user)
      elsif role == 'visitor'
        @list.visitors << invited_user unless @list.visitors.include?(invited_user)
      end

      @list.update(share_token: SecureRandom.hex(10)) unless @list.share_token.present?
      create_share_notification(@list)

      # current_user est l’invitant
      ListMailer.invite_editor(@list, invited_user, current_user, role).deliver_now

      redirect_to @list, notice: I18n.t('lists.invite.success')
    else
      redirect_to @list, alert: I18n.t('lists.invite.failure')
    end
  end


  def change_role
    user = User.find(params[:user_id])
    role = params[:role]

    notice =
      case role
      when 'remove'
        if @list.editors.delete(user) || @list.visitors.delete(user)
          I18n.t('lists.role.remove.success')
        else
          I18n.t('lists.role.remove.failure')
        end
      when 'editor'
        @list.editors << user unless @list.editors.include?(user)
        @list.visitors.delete(user)
        I18n.t('lists.role.editor')
      when 'visitor'
        @list.visitors << user unless @list.visitors.include?(user)
        @list.editors.delete(user)
        I18n.t('lists.role.visitor')
      else
        I18n.t('lists.role.invalid')
      end

    redirect_to @list, notice: notice
  end

  def remove_user
    user = User.find(params[:user_id])
    notice =
      if @list.editors.exists?(user.id) || @list.visitors.exists?(user.id)
        @list.editors.delete(user)
        @list.visitors.delete(user)
        I18n.t('lists.remove.user.success')
      else
        I18n.t('lists.remove.user.failure')
      end
    redirect_to @list, notice: notice
  end

  def load_more_oeuvres
    if params[:slug].present?
      @list = List.friendly.find_by(slug: params[:slug])
  
      unless @list
        head :not_found and return
      end
  
      # on pourrait ici charger seulement les oeuvres rattachées à la liste
      @oeuvres = @list.oeuvres.offset(params[:offset]).limit(10)
    else
      # mode création ➔ on affiche toutes les oeuvres validées
      @oeuvres = Oeuvre.where(validation: true).order(:nom_oeuvre).offset(params[:offset]).limit(10)
    end
  
    render partial: 'oeuvres_list', collection: @oeuvres, as: :oeuvre
  end
  def load_more_designers
    if params[:slug].present?
      @list = List.friendly.find_by(slug: params[:slug])
  
      unless @list
        head :not_found and return
      end
  
      @designers = @list.designers.offset(params[:offset]).limit(10)
    else
      @designers = Designer.where(validation: true).order(:nom).offset(params[:offset]).limit(10)
    end
  
    render partial: 'designers_list', collection: @designers, as: :designer
  end

  private

  def set_list
    @list = List.friendly.find_by(slug: params[:slug])
    redirect_to lists_path, alert: I18n.t('lists.not_found') unless @list
  end

  def list_params
    params.require(:list).permit(:name, designer_ids: [], oeuvre_ids: [])
  end

  def create_share_notification(list)
    message = I18n.t('lists.shared_message', name: list.name)
    list.editors.each do |editor|
      Notification.create(user_id: editor.id, notifiable: list, message: message)
    end
  end
end
