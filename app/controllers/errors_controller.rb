class ErrorsController < ApplicationController
  def not_found
    respond_to do |format|
      format.html { render status: :not_found }
      format.all  { head :not_found }
    end
  end

  def internal_server_error
    respond_to do |format|
      format.html { render status: :internal_server_error }
      format.all  { head :internal_server_error }
    end
  end

  def unprocessable_entity
    respond_to do |format|
      format.html { render status: :unprocessable_entity }
      format.all  { head :unprocessable_entity }
    end
  end

  def forbidden
    respond_to do |format|
      format.html { render status: :forbidden }
      format.all  { head :forbidden }
    end
  end
end
