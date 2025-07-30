module Api
  module V1
    class ListEditorsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_list_editor, only: [:show, :update, :destroy]

      def index
        @list_editors = List_editor.all
        render json: @list_editors
      end

      def show
        render json: @list_editor
      end

      def create
        @list_editor = List_editor.new(list_editor_params)
        if @list_editor.save
          render json: @list_editor, status: :created
        else
          render json: @list_editor.errors, status: :unprocessable_entity
        end
      end

      def update
        if @list_editor.update(list_editor_params)
          render json: @list_editor
        else
          render json: @list_editor.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @list_editor.destroy
        head :no_content
      end

      private

      def set_list_editor
        @list_editor = List_editor.find(params[:id])
      end

      def list_editor_params
        params.require(:list_editor).permit(:list_id, :user_id)
      end
    end
  end
end
