module Api
  module V1
    class NotionsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_notion, only: [:show, :update, :destroy]

      def index
        @notions = Notion.all
        render json: @notions
      end

      def show
        render json: @notion
      end

      def create
        @notion = Notion.new(notion_params)
        if @notion.save
          render json: @notion, status: :created
        else
          render json: @notion.errors, status: :unprocessable_entity
        end
      end

      def update
        if @notion.update(notion_params)
          render json: @notion
        else
          render json: @notion.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @notion.destroy
        head :no_content
      end

      private

      def set_notion
        @notion = Notion.find(params[:id])
      end

      def notion_params
        params.require(:notion).permit(:nom_notions)
      end
    end
  end
end
