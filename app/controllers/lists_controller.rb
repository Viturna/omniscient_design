class ListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_list, only: [
      :show, :edit, :update, :destroy, :invite_editors,
      :change_role, :remove_user, :toggle_privacy,
      :remove_designer, :remove_oeuvre, :remove_studio,
      :add_oeuvre, :add_designer, :add_studio 
    ]
    
  def index
    @lists = current_user.lists
    @editor_lists = current_user.editable_lists
    @visitor_lists = current_user.visitor_lists
    @current_page = 'listes'
  end

  def show
    @current_page = 'listes'
    @countries = Country.where(id: DesignerCountry.select(:country_id))
                        .or(Country.where(id: StudioCountry.select(:country_id)))
                        .distinct.order(:country)
    @notions = Notion.all

    # Designers
    selected_designer_ids = @list.designer_ids
    @selected_designers = Designer.where(id: selected_designer_ids, validation: true).order(:nom)
    @other_designers = Designer.where(validation: true)
                               .where.not(id: selected_designer_ids)
                               .order(:nom)
                               .page(params[:designers_page]).per(10)

    selected_studio_ids = @list.studio_ids
    @selected_studios = Studio.where(id: selected_studio_ids, validation: true).order(:nom)
    @other_studios = Studio.where(validation: true)
                           .where.not(id: selected_studio_ids)
                           .order(:nom)
                           .page(params[:studios_page]).per(10)

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

      selected_studio_ids = @list.studio_ids
      @selected_studios = Studio.where(id: selected_studio_ids, validation: true).order(:nom)
      @other_studios = Studio.where(validation: true)
                             .where.not(id: selected_studio_ids)
                             .order(:nom)
                             .page(params[:studios_page]).per(10)

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
  end


 def create
    @list = List.new(list_params)
    @list.user = current_user

    if @list.save
      # REDIRECTION ETAPE 2 : On va sur la liste avec le paramètre newly_created
      redirect_to list_path(@list, newly_created: true), notice: I18n.t('list.create.success', default: "Liste créée ! Ajoutez maintenant vos éléments.")
    else
      flash.now[:alert] = I18n.t('list.create.failure', default: "Erreur lors de la création.")
      render :new, status: :unprocessable_entity
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
  def remove_studio
    studio = Studio.find(params[:studio_id])
    notice = if @list.studios.delete(studio)
               I18n.t('lists.remove.studio.success', default: "Studio retiré de la liste")
             else
               I18n.t('lists.remove.studio.failure', default: "Erreur lors du retrait du studio")
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
  def add_studio
    studio = Studio.find(params[:studio_id])
    if @list.studios.include?(studio)
      redirect_to request.referer, alert: I18n.t('lists.add.studio.exists', default: "Ce studio est déjà dans la liste")
    else
      if @list.studios << studio
        redirect_to request.referer, notice: I18n.t('lists.add.studio.success', default: "Studio ajouté à la liste")
      else
        redirect_to request.referer, alert: I18n.t('lists.add.studio.failure', default: "Erreur lors de l'ajout du studio")
      end
    end
  end
  def filtered_scopes
    oeuvres   = Oeuvre.where(validation: true)
    designers = Designer.where(validation: true)
    studios   = Studio.where(validation: true)
    # ----- années -----
    if params[:start_year].present? && params[:end_year].present?
      sy, ey = params[:start_year].to_i, params[:end_year].to_i
      if sy > 0 && ey > 0 && sy <= ey
        designers = designers.where(date_naissance: sy..ey)
        studios   = studios.where(date_creation: sy..ey)
        oeuvres   = oeuvres.where(date_oeuvre: sy..ey)
      end
    end

    # ----- domaines -----
    domaines_params = params.dig(:list, :domaine)
      if domaines_params.present?
        domaine_ids = Array(domaines_params).reject(&:blank?)
        if domaine_ids.any?
          designers = designers.joins(:domaines).where(domaines: { id: domaine_ids }).distinct
          studios   = studios.joins(:domaines).where(domaines: { id: domaine_ids }).distinct
          oeuvres   = oeuvres.joins(:domaines).where(domaines: { id: domaine_ids }).distinct
        end
      end


    # ----- notions -----
    notions_params = params[:notions] || params.dig(:list, :notions)
    if notions_params.present?
      notion_ids = Array(notions_params).reject(&:blank?)
      designers  = designers.joins(:notions).where(notions: { id: notion_ids }).distinct
      oeuvres    = oeuvres.joins(:notions).where(notions: { id: notion_ids }).distinct
    end

    # ----- pays -----
    countries_params = params[:country] || params.dig(:list, :country)
      if countries_params.present?
        country_ids = Array(countries_params).reject(&:blank?)
        if country_ids.any?
          designers = designers.joins(:designer_countries).where(designer_countries: { country_id: country_ids }).distinct
          # Si StudioCountry existe :
          studios   = studios.joins(:studio_countries).where(studio_countries: { country_id: country_ids }).distinct
          oeuvres   = oeuvres.joins(designers: :designer_countries).where(designer_countries: { country_id: country_ids }).distinct
        end
      end


    [oeuvres, designers, studios]
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

  def search_items
    query = params[:q].to_s.downcase.strip
    type = params[:type]
    limit = 10 # Limite pour ne pas surcharger la vue

    case type
    when 'studios'
      @studios = Studio.where(validation: true)
                       .where("LOWER(nom) LIKE ?", "%#{query}%")
                       .limit(limit)
      render partial: 'studios_list', collection: @studios, as: :studio

    when 'designers'
      @designers = Designer.where(validation: true)
                           .where("LOWER(nom) LIKE ? OR LOWER(prenom) LIKE ?", "%#{query}%", "%#{query}%")
                           .limit(limit)
      render partial: 'designers_list', collection: @designers, as: :designer

    when 'oeuvres'
      @oeuvres = Oeuvre.where(validation: true)
                       .where("LOWER(nom_oeuvre) LIKE ?", "%#{query}%")
                       .limit(limit)
      render partial: 'oeuvres_list', collection: @oeuvres, as: :oeuvre

    else
      head :bad_request # Renvoie une erreur 400 si le type est inconnu
    end
  end



def load_more_oeuvres
  offset = params[:offset].to_i
  if params[:slug].present?
    @list = List.friendly.find_by(slug: params[:slug])
    selected_oeuvre_ids = @list.oeuvre_ids
    @oeuvres = Oeuvre.where(validation: true)
                     .where.not(id: selected_oeuvre_ids)
                     .order(:nom_oeuvre)
                     .offset(offset)
                     .limit(10)
  else
    @oeuvres = Oeuvre.where(validation: true)
                     .order(:nom_oeuvre)
                     .offset(offset)
                     .limit(10)
  end
  render partial: 'oeuvres_list', collection: @oeuvres, as: :oeuvre
end

def load_more_designers
  offset = params[:offset].to_i
  if params[:slug].present?
    @list = List.friendly.find_by(slug: params[:slug])
    selected_designer_ids = @list.designer_ids
    @designers = Designer.where(validation: true)
                         .where.not(id: selected_designer_ids)
                         .order(:nom)
                         .offset(offset)
                         .limit(10)
  else
    @designers = Designer.where(validation: true)
                         .order(:nom)
                         .offset(offset)
                         .limit(10)
  end
  render partial: 'designers_list', collection: @designers, as: :designer
end

  def load_more_studios
    offset = params[:offset].to_i
    if params[:slug].present?
      @list = List.friendly.find_by(slug: params[:slug])
      selected_studio_ids = @list.studio_ids
      @studios = Studio.where(validation: true)
                          .where.not(id: selected_studio_ids)
                          .order(:nom)
                          .offset(offset)
                          .limit(10)
    else
      @studios = Studio.where(validation: true)
                          .order(:nom)
                          .offset(offset)
                          .limit(10)
    end
    render partial: 'studios_list', collection: @studios, as: :studio
  end


  def set_list
    @list = List.friendly.find_by(slug: params[:slug])
    redirect_to lists_path, alert: I18n.t('lists.not_found') unless @list
  end

  def list_params
    params.require(:list).permit(:name, :public, designer_ids: [], studio_ids: [], oeuvre_ids: [])
  end

  def create_share_notification(list)
    title = "Liste partagée"
    message = I18n.t('lists.shared_message', name: list.name)
    
    list.editors.each do |editor|
      Notification.create(
        user_id: editor.id, 
        notifiable: list, 
        title: title,
        message: message,
        status: :unread
      )
    end
  end
end
