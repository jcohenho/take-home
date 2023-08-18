# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users' do
  describe 'POST /populate' do
    it 'enqueues the user creation job' do
      expect { post '/api/users/populate' }
        .to have_enqueued_job(IngestUsersJob).exactly(:once)
    end

    it 'returns a 200' do
      post '/api/users/populate'
      expect(response).to have_http_status(:ok)
    end
  end
end
