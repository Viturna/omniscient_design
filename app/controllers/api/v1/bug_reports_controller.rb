module Api
  module V1
    class BugReportsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_bug_report, only: [:show, :update, :destroy]

      def index
        @bug_reports = Bug_report.all
        render json: @bug_reports
      end

      def show
        render json: @bug_report
      end

      def create
        @bug_report = Bug_report.new(bug_report_params)
        if @bug_report.save
          render json: @bug_report, status: :created
        else
          render json: @bug_report.errors, status: :unprocessable_entity
        end
      end

      def update
        if @bug_report.update(bug_report_params)
          render json: @bug_report
        else
          render json: @bug_report.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @bug_report.destroy
        head :no_content
      end

      private

      def set_bug_report
        @bug_report = Bug_report.find(params[:id])
      end

      def bug_report_params
        params.require(:bug_report).permit(:user_id, :message)
      end
    end
  end
end
