# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.0'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.0.7'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 5.0'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  # Rspec testing framework https://github.com/rspec/rspec-rails
  gem 'rspec-rails', '~> 6.0.0'
  # Fixtures framework https://github.com/thoughtbot/factory_bot_rails
  gem 'factory_bot_rails'
  # Library for generating fake test data https://github.com/faker-ruby/faker
  gem 'faker'
end

group :development do
  # Ruby linter and formatter https://github.com/rubocop/rubocop
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
end
