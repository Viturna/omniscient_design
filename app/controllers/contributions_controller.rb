class ContributionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @references = current_user.references + current_user.rejected_references.map do |rejected_reference|
      Reference.new(
        nom_reference: rejected_reference.nom_reference,
        created_at: rejected_reference.created_at,
        validation: false,
        user: rejected_reference.user,
        rejection_reason: rejected_reference.reason
      )
    end
    @designers = current_user.designers + current_user.rejected_designers.map do |rejected_designer|
      Designer.new(
        nom: rejected_designer.nom,
        prenom: rejected_designer.prenom,
        created_at: rejected_designer.created_at,
        validation: false,
        user: rejected_designer.user,
        rejection_reason: rejected_designer.reason
      )
    end
    @studios = current_user.studios + current_user.rejected_studios.map do |rejected_studio|
      Studio.new(
        nom: rejected_studio.nom,
        created_at: rejected_studio.created_at,
        validation: false,
        user: rejected_studio.user,
        rejection_reason: rejected_studio.reason
      )
    end
    @references = @references.sort_by(&:created_at).reverse
    @designers = @designers.sort_by(&:created_at).reverse
    @studios = @studios.sort_by(&:created_at).reverse
  end
end
