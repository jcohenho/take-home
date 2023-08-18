# frozen_string_literal: true

class IngestUsersJob < ApplicationJob
  queue_as :default

  def perform
    request = RandomUserRequest.new
    response = request.call
    response[:results].each do |user|
      User.create({
                    email: user[:email],
                    first_name: user[:name][:first],
                    last_name: user[:name][:last],
                    registered_at: user[:registered][:date],
                    phone_number: user[:phone],
                    picture: user[:picture][:thumbnail]
                  })
    end
  end
end
