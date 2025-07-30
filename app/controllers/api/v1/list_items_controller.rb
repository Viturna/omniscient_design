module Api
  module V1
    class ListItemsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_list_item, only: [:show, :update, :destroy]

      def index
        @list_items = List_item.all
        render json: @list_items
      end

      def show
        render json: @list_item
      end

      def create
        @list_item = List_item.new(list_item_params)
        if @list_item.save
          render json: @list_item, status: :created
        else
          render json: @list_item.errors, status: :unprocessable_entity
        end
      end

      def update
        if @list_item.update(list_item_params)
          render json: @list_item
        else
          render json: @list_item.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @list_item.destroy
        head :no_content
      end

      private

      def set_list_item
        @list_item = List_item.find(params[:id])
      end

      def list_item_params
        params.require(:list_item).permit(:list_id, :oeuvre_id)
      end
    end
  end
end
