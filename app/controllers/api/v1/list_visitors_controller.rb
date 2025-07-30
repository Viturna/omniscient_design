module Api
  module V1
    class ListVisitorsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_list_visitor, only: [:show, :update, :destroy]

      def index
        @list_visitors = List_visitor.all
        render json: @list_visitors
      end

      def show
        render json: @list_visitor
      end

      def create
        @list_visitor = List_visitor.new(list_visitor_params)
        if @list_visitor.save
          render json: @list_visitor, status: :created
        else
          render json: @list_visitor.errors, status: :unprocessable_entity
        end
      end

      def update
        if @list_visitor.update(list_visitor_params)
          render json: @list_visitor
        else
          render json: @list_visitor.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @list_visitor.destroy
        head :no_content
      end

      private

      def set_list_visitor
        @list_visitor = List_visitor.find(params[:id])
      end

      def list_visitor_params
        params.require(:list_visitor).permit(:list_id, :user_id)
      end
    end
  end
end
