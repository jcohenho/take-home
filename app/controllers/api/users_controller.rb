# frozen_string_literal: true

module Api
  class UsersController < ApplicationController
    def populate
      IngestUsersJob.perform_later
      head :ok
    end
  end
end
