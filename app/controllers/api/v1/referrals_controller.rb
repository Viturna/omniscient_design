module Api
  module V1
    class ReferralsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_referral, only: [:show, :update, :destroy]

      def index
        @referrals = Referral.all
        render json: @referrals
      end

      def show
        render json: @referral
      end

      def create
        @referral = Referral.new(referral_params)
        if @referral.save
          render json: @referral, status: :created
        else
          render json: @referral.errors, status: :unprocessable_entity
        end
      end

      def update
        if @referral.update(referral_params)
          render json: @referral
        else
          render json: @referral.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @referral.destroy
        head :no_content
      end

      private

      def set_referral
        @referral = Referral.find(params[:id])
      end

      def referral_params
        params.require(:referral).permit(:email, :user_id)
      end
    end
  end
end
