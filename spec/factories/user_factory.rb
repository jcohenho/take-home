# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    email { "#{first_name}.#{last_name}@example.com" }
    phone_number { Faker::PhoneNumber.phone_number }
    picture { Faker::Avatar.image(size: '50x50') }
    registered_at { Faker::Time.unique.between_dates(from: Time.zone.today - 1, to: 2.years.ago, period: :all) }
  end
end
