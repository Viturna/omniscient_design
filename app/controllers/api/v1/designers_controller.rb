module Api
  module V1
    class DesignersController < ApplicationController
      before_action :authenticate_user!
      before_action :set_designer, only: [:show, :update, :destroy]

      def index
        @designers = Designer.all
        render json: @designers
      end

      def show
        render json: @designer
      end

      def create
        @designer = Designer.new(designer_params)
        if @designer.save
          render json: @designer, status: :created
        else
          render json: @designer.errors, status: :unprocessable_entity
        end
      end

      def update
        if @designer.update(designer_params)
          render json: @designer
        else
          render json: @designer.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @designer.destroy
        head :no_content
      end

      private

      def set_designer
        @designer = Designer.find(params[:id])
      end

      def designer_params
        params.require(:designer).permit(:prenom, :nom, :user_id, :date_naissance, :date_deces, :image, :presentation_generale, :formation_et_influences, :style_ou_philosophie, :creations_majeures, :heritage_et_impact, :validation, :slug, :rejection_reason)
      end
    end
  end
end
