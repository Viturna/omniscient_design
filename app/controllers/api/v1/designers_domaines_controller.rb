module Api
  module V1
    class DesignersDomainesController < ApplicationController
      before_action :authenticate_user!
      before_action :set_designers_domaine, only: [:show, :update, :destroy]

      def index
        @designers_domaines = Designers_domaine.all
        render json: @designers_domaines
      end

      def show
        render json: @designers_domaine
      end

      def create
        @designers_domaine = Designers_domaine.new(designers_domaine_params)
        if @designers_domaine.save
          render json: @designers_domaine, status: :created
        else
          render json: @designers_domaine.errors, status: :unprocessable_entity
        end
      end

      def update
        if @designers_domaine.update(designers_domaine_params)
          render json: @designers_domaine
        else
          render json: @designers_domaine.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @designers_domaine.destroy
        head :no_content
      end

      private

      def set_designers_domaine
        @designers_domaine = Designers_domaine.find(params[:id])
      end

      def designers_domaine_params
        params.require(:designers_domaine).permit(:designer_id, :domaine_id)
      end
    end
  end
end
