module Api
  module V1
    class SuivisController < ApplicationController
      before_action :authenticate_user!
      before_action :set_suivi, only: [:show, :update, :destroy]

      def index
        @suivis = Suivi.all
        render json: @suivis
      end

      def show
        render json: @suivi
      end

      def create
        @suivi = Suivi.new(suivi_params)
        if @suivi.save
          render json: @suivi, status: :created
        else
          render json: @suivi.errors, status: :unprocessable_entity
        end
      end

      def update
        if @suivi.update(suivi_params)
          render json: @suivi
        else
          render json: @suivi.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @suivi.destroy
        head :no_content
      end

      private

      def set_suivi
        @suivi = Suivi.find(params[:id])
      end

      def suivi_params
        params.require(:suivi).permit(:user_id, :nb_references_emises, :nb_references_validees, :nb_references_refusees)
      end
    end
  end
end
