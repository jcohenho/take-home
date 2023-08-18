# frozen_string_literal: true

module Api
  class UsersController < ApplicationController
    def populate
      IngestUsersJob.perform_later
      head :ok
    end

    def clerks
      cursor = Cursor.new user_params
      users = cursor.call

      render json: users
    rescue Errors::LimitRangeError, ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :bad_request
    end

    private

    def user_params
      params.permit(:limit, :starting_after, :ending_before, :email)
    end
  end
end
