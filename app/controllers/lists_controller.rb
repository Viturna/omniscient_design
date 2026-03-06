class ListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_list, only: [
      :show, :edit, :update, :destroy, :invite_editors,
      :change_role, :remove_user, :toggle_privacy,
      :remove_designer, :remove_reference, :remove_studio,
      :add_reference, :add_designer, :add_studio 
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
    selected_reference_ids = @list.reference_ids
    @selected_references = Reference.where(id: selected_reference_ids, validation: true).order(:nom_reference)
    @other_references = Reference.where(validation: true)
                           .where.not(id: selected_reference_ids)
                           .order(:nom_reference)
                           .page(params[:references_page]).per(10)

    # Autorisation
    if @list.share_token.present? && @list.share_token == params[:share_token]
      render :show
    elsif current_user.admin? || @list.user == current_user || @list.editors.include?(current_user) || @list.visitors.include?(current_user)
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
      selected_reference_ids = @list.reference_ids
      @selected_references = Reference.where(id: selected_reference_ids, validation: true).order(:nom_reference)
      @other_references = Reference.where(validation: true)
                             .where.not(id: selected_reference_ids)
                             .order(:nom_reference)
                             .page(params[:references_page]).per(10)

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

  def add_reference
    @list = List.friendly.find(params[:slug]) 
    
    @reference = Reference.find(params[:reference_id])

    unless @list.references.include?(@reference)
      @list.references << @reference
    end

    redirect_to save_modal_reference_path(@reference)
  end

  def remove_reference
    @list = List.friendly.find(params[:slug]) 
    
    @reference = Reference.find(params[:reference_id])

    @list.references.delete(@reference)

    redirect_to save_modal_reference_path(@reference)
  end

  def add_designer
    @list = List.friendly.find(params[:slug])
    @designer = Designer.find(params[:designer_id])

    unless @list.designers.include?(@designer)
      @list.designers << @designer
    end

    redirect_to save_modal_designer_path(@designer)
  end

  def remove_designer
    @list = List.friendly.find(params[:slug])
    @designer = Designer.find(params[:designer_id])

    @list.designers.delete(@designer)

    redirect_to save_modal_designer_path(@designer)
  end

  def add_studio
    @list = List.friendly.find(params[:slug])
    @studio = Studio.find(params[:studio_id])

    unless @list.studios.include?(@studio)
      @list.studios << @studio
    end

    redirect_to save_modal_studio_path(@studio)
  end

  def remove_studio
    @list = List.friendly.find(params[:slug])
    @studio = Studio.find(params[:studio_id])

    @list.studios.delete(@studio)

    redirect_to save_modal_studio_path(@studio)
  end
  
  def filtered_scopes
    references   = Reference.where(validation: true)
    designers = Designer.where(validation: true)
    studios   = Studio.where(validation: true)
    # ----- années -----
    if params[:start_year].present? && params[:end_year].present?
      sy, ey = params[:start_year].to_i, params[:end_year].to_i
      if sy > 0 && ey > 0 && sy <= ey
        designers = designers.where(date_naissance: sy..ey)
        studios   = studios.where(date_creation: sy..ey)
        references   = references.where(date_reference: sy..ey)
      end
    end

    # ----- domaines -----
    domaines_params = params.dig(:list, :domaine)
      if domaines_params.present?
        domaine_ids = Array(domaines_params).reject(&:blank?)
        if domaine_ids.any?
          designers = designers.joins(:domaines).where(domaines: { id: domaine_ids }).distinct
          studios   = studios.joins(:domaines).where(domaines: { id: domaine_ids }).distinct
          references   = references.joins(:domaines).where(domaines: { id: domaine_ids }).distinct
        end
      end


    # ----- notions -----
    notions_params = params[:notions] || params.dig(:list, :notions)
    if notions_params.present?
      notion_ids = Array(notions_params).reject(&:blank?)
      designers  = designers.joins(:notions).where(notions: { id: notion_ids }).distinct
      references    = references.joins(:notions).where(notions: { id: notion_ids }).distinct
    end

    # ----- pays -----
    countries_params = params[:country] || params.dig(:list, :country)
      if countries_params.present?
        country_ids = Array(countries_params).reject(&:blank?)
        if country_ids.any?
          designers = designers.joins(:designer_countries).where(designer_countries: { country_id: country_ids }).distinct
          # Si StudioCountry existe :
          studios   = studios.joins(:studio_countries).where(studio_countries: { country_id: country_ids }).distinct
          references   = references.joins(designers: :designer_countries).where(designer_countries: { country_id: country_ids }).distinct
        end
      end


    [references, designers, studios]
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

    when 'references'
      @references = Reference.where(validation: true)
                       .where("LOWER(nom_reference) LIKE ?", "%#{query}%")
                       .limit(limit)
      render partial: 'references_list', collection: @references, as: :reference

    else
      head :bad_request # Renvoie une erreur 400 si le type est inconnu
    end
  end



def load_more_references
  offset = params[:offset].to_i
  if params[:slug].present?
    @list = List.friendly.find_by(slug: params[:slug])
    selected_reference_ids = @list.reference_ids
    @references = Reference.where(validation: true)
                     .where.not(id: selected_reference_ids)
                     .order(:nom_reference)
                     .offset(offset)
                     .limit(10)
  else
    @references = Reference.where(validation: true)
                     .order(:nom_reference)
                     .offset(offset)
                     .limit(10)
  end
  render partial: 'references_list', collection: @references, as: :reference
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
    params.require(:list).permit(:name, :public, designer_ids: [], studio_ids: [], reference_ids: [])
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
