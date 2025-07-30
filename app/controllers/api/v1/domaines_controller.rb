module Api
  module V1
    class DomainesController < ApplicationController
      before_action :authenticate_user!
      before_action :set_domaine, only: [:show, :update, :destroy]

      def index
        @domaines = Domaine.all
        render json: @domaines
      end

      def show
        render json: @domaine
      end

      def create
        @domaine = Domaine.new(domaine_params)
        if @domaine.save
          render json: @domaine, status: :created
        else
          render json: @domaine.errors, status: :unprocessable_entity
        end
      end

      def update
        if @domaine.update(domaine_params)
          render json: @domaine
        else
          render json: @domaine.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @domaine.destroy
        head :no_content
      end

      private

      def set_domaine
        @domaine = Domaine.find(params[:id])
      end

      def domaine_params
        params.require(:domaine).permit(:nom_domaine)
      end
    end
  end
end
