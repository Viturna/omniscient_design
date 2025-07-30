module Api
  module V1
    class ListsOeuvresController < ApplicationController
      before_action :authenticate_user!
      before_action :set_lists_oeuvre, only: [:show, :update, :destroy]

      def index
        @lists_oeuvres = Lists_oeuvre.all
        render json: @lists_oeuvres
      end

      def show
        render json: @lists_oeuvre
      end

      def create
        @lists_oeuvre = Lists_oeuvre.new(lists_oeuvre_params)
        if @lists_oeuvre.save
          render json: @lists_oeuvre, status: :created
        else
          render json: @lists_oeuvre.errors, status: :unprocessable_entity
        end
      end

      def update
        if @lists_oeuvre.update(lists_oeuvre_params)
          render json: @lists_oeuvre
        else
          render json: @lists_oeuvre.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @lists_oeuvre.destroy
        head :no_content
      end

      private

      def set_lists_oeuvre
        @lists_oeuvre = Lists_oeuvre.find(params[:id])
      end

      def lists_oeuvre_params
        params.require(:lists_oeuvre).permit(:list_id, :oeuvre_id)
      end
    end
  end
end
