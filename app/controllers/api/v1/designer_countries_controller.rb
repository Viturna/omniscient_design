module Api
  module V1
    class DesignerCountriesController < ApplicationController
      before_action :authenticate_user!
      before_action :set_designer_countrie, only: [:show, :update, :destroy]

      def index
        @designer_countries = Designer_countrie.all
        render json: @designer_countries
      end

      def show
        render json: @designer_countrie
      end

      def create
        @designer_countrie = Designer_countrie.new(designer_countrie_params)
        if @designer_countrie.save
          render json: @designer_countrie, status: :created
        else
          render json: @designer_countrie.errors, status: :unprocessable_entity
        end
      end

      def update
        if @designer_countrie.update(designer_countrie_params)
          render json: @designer_countrie
        else
          render json: @designer_countrie.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @designer_countrie.destroy
        head :no_content
      end

      private

      def set_designer_countrie
        @designer_countrie = Designer_countrie.find(params[:id])
      end

      def designer_countrie_params
        params.require(:designer_countrie).permit(:designer_id, :country_id)
      end
    end
  end
end
