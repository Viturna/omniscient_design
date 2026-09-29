class Admin::SchoolContactsController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  before_action :authenticate_admin!
  before_action :set_school_contact, only: %i[update destroy toggle_status]

  def index
    @current_page = 'school_contacts'
    @filter = params[:filter] || 'all'

    @contacts = SchoolContact.all.recent
    @contacts = @contacts.where(request_type: 'devis_monopole') if @filter == 'quotes'
    @contacts = @contacts.where(request_type: 'contact') if @filter == 'contacts'
    @contacts = @contacts.where(status: :pending) if @filter == 'pending'

    @pending_count = SchoolContact.where(status: :pending).count
    @quotes_count = SchoolContact.where(request_type: 'devis_monopole').count
    @contacts_count = SchoolContact.where(request_type: 'contact').count
  end

  def update
    if @school_contact.update(school_contact_params)
      redirect_to admin_school_contacts_path, notice: 'Demande mise à jour.'
    else
      redirect_to admin_school_contacts_path, alert: 'Erreur lors de la mise à jour.'
    end
  end

  def toggle_status
    new_status = @school_contact.pending? ? :processed : :pending
    @school_contact.update(status: new_status)
    redirect_to admin_school_contacts_path(filter: params[:filter]), notice: "Statut mis à jour : #{new_status == :processed ? 'Traité' : 'En attente'}."
  end

  def destroy
    @school_contact.destroy
    redirect_to admin_school_contacts_path(filter: params[:filter]), notice: 'Demande supprimée.'
  end

  private

  def set_school_contact
    @school_contact = SchoolContact.find(params[:id])
  end

  def school_contact_params
    params.require(:school_contact).permit(:status)
  end

  def authenticate_admin!
    return if current_user&.admin?

    redirect_to root_path, alert: 'Accès interdit.'
  end
end
