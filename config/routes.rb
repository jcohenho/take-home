# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    resources :users, only: [] do
      collection do
        post 'populate'
        get 'clerks'
      end
    end
  end
end
