# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    resources :users, only: [] do
      post 'populate', on: :collection
    end
  end
end
