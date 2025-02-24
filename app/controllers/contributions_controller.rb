class ContributionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @oeuvres = current_user.oeuvres + current_user.rejected_oeuvres.map do |rejected_oeuvre|
      Oeuvre.new(
        nom_oeuvre: rejected_oeuvre.nom_oeuvre,
        created_at: rejected_oeuvre.created_at,
        validation: false,
        user: rejected_oeuvre.user,
        rejection_reason: rejected_oeuvre.reason
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
  end
end
