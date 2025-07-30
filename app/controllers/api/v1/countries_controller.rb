module Api
  module V1
    class CountriesController < ApplicationController
      before_action :authenticate_user!
      before_action :set_countrie, only: [:show, :update, :destroy]

      def index
        @countries = Countrie.all
        render json: @countries
      end

      def show
        render json: @countrie
      end

      def create
        @countrie = Countrie.new(countrie_params)
        if @countrie.save
          render json: @countrie, status: :created
        else
          render json: @countrie.errors, status: :unprocessable_entity
        end
      end

      def update
        if @countrie.update(countrie_params)
          render json: @countrie
        else
          render json: @countrie.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @countrie.destroy
        head :no_content
      end

      private

      def set_countrie
        @countrie = Countrie.find(params[:id])
      end

      def countrie_params
        params.require(:countrie).permit(:country)
      end
    end
  end
end
