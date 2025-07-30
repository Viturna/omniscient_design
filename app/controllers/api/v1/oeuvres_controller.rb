module Api
  module V1
    class OeuvresController < ApplicationController
      before_action :authenticate_user!
      before_action :set_oeuvre, only: [:show, :update, :destroy]

      def index
        @oeuvres = Oeuvre.all
        render json: @oeuvres
      end

      def show
        render json: @oeuvre
      end

      def create
        @oeuvre = Oeuvre.new(oeuvre_params)
        if @oeuvre.save
          render json: @oeuvre, status: :created
        else
          render json: @oeuvre.errors, status: :unprocessable_entity
        end
      end

      def update
        if @oeuvre.update(oeuvre_params)
          render json: @oeuvre
        else
          render json: @oeuvre.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @oeuvre.destroy
        head :no_content
      end

      private

      def set_oeuvre
        @oeuvre = Oeuvre.find(params[:id])
      end

      def oeuvre_params
        params.require(:oeuvre).permit(:nom_oeuvre, :domaine_id, :date_oeuvre, :image, :presentation_generale, :user_id, :validation, :slug, :rejection_reason)
      end
    end
  end
end
