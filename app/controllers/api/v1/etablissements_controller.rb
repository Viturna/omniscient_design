module Api
  module V1
    class EtablissementsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_etablissement, only: [:show, :update, :destroy]

      def index
        @etablissements = Etablissement.all
        render json: @etablissements
      end

      def show
        render json: @etablissement
      end

      def create
        @etablissement = Etablissement.new(etablissement_params)
        if @etablissement.save
          render json: @etablissement, status: :created
        else
          render json: @etablissement.errors, status: :unprocessable_entity
        end
      end

      def update
        if @etablissement.update(etablissement_params)
          render json: @etablissement
        else
          render json: @etablissement.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @etablissement.destroy
        head :no_content
      end

      private

      def set_etablissement
        @etablissement = Etablissement.find(params[:id])
      end

      def etablissement_params
        params.require(:etablissement).permit(:nom_etablissement)
      end
    end
  end
end
