class TipClicksController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
  skip_before_action :verify_authenticity_token

  def create
    TipClick.create
    head :ok
  end
end
