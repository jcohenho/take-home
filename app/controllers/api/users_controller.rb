# frozen_string_literal: true

module Api
  class UsersController < ApplicationController
    def populate
      IngestUsersJob.perform_later
      head :ok
    end

    def clerks
      limit = user_params.fetch(:limit, 10).to_i
      raise Errors::LimitRangeError unless limit.between?(1, 100)

      users = User.all.limit(limit).order(registered_at: :desc, id: :asc)
      if user_params[:starting_after].present?
        user_after = User.find user_params[:starting_after]
        users = users.where('registered_at > ?', user_after.registered_at)
      end
      if user_params[:ending_before].present?
        user_before = User.find user_params[:ending_before]
        users = users.where('registered_at < ?', user_before.registered_at)
      end
      users = users.where('email ilike ?', "%#{user_params[:email]}%") if user_params[:email].present?
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
