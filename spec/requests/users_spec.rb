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

  describe 'GET /clerks' do
    context 'without params' do
      before do
        create_list(:user, 20)
      end

      it 'returns a list of 10 users ordered by latest registration date' do
        get '/api/users/clerks'

        data = response.parsed_body
        expect(data.size).to eq(10)
        expect(data.first['registered_at']).to be > data.second['registered_at']
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with params' do
      let!(:jeremy) { create(:user, first_name: 'Jeremy', email: 'jeremy@example.com', registered_at: 6.hours.ago) }
      let!(:mary) { create(:user, first_name: 'Mary', email: 'mary@clerk.com', registered_at: 4.hours.ago) }
      let!(:jeff) { create(:user, first_name: 'Jeff', email: 'jeff@clerk.com', registered_at: 10.hours.ago) }
      let!(:cory) { create(:user, first_name: 'Cory', email: 'cory@example.com', registered_at: 8.hours.ago) }

      it 'returns the correct number of results when a limit param is passed' do
        get '/api/users/clerks', params: { limit: 3 }

        expect(response.parsed_body.size).to eq(3)
      end

      it 'returns the results in reverse chronological order' do
        get '/api/users/clerks', params: { limit: 3 }

        data = response.parsed_body
        expect(data.pluck('first_name')).to eq(%w[Mary Jeremy Cory])
      end

      it 'returns the users that registered after Cory' do
        get '/api/users/clerks', params: { starting_after: cory.id }

        data = response.parsed_body
        expect(data.pluck('first_name')).to eq(%w[Mary Jeremy])
      end

      it 'returns the users that registered before Jeremy' do
        get '/api/users/clerks', params: { ending_before: jeremy.id }

        data = response.parsed_body
        expect(data.pluck('first_name')).to eq(%w[Cory Jeff])
      end

      it 'filters the results by email' do
        get '/api/users/clerks', params: { email: 'jeff@clerk.com' }

        data = response.parsed_body
        expect(data.first['first_name']).to eq('Jeff')
      end

      it 'filters the results by partial email matches' do
        get '/api/users/clerks', params: { email: '@clerk.com' }

        data = response.parsed_body
        expect(data.pluck('first_name')).to eq(%w[Mary Jeff])
      end

      it 'returns the correct results when using multiple params' do
        get '/api/users/clerks',
            params: { starting_after: jeff.id, ending_before: mary.id, email: '@example.com', limit: 2 }

        data = response.parsed_body
        expect(data.pluck('first_name')).to eq(%w[Jeremy Cory])
      end

      it 'returns a 400 when passing an out of range limit param' do
        get '/api/users/clerks',
            params: { limit: 200 }

        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a 400 when passing an invalid user id' do
        get '/api/users/clerks',
            params: { starting_after: 999 }

        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
