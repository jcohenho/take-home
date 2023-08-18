# frozen_string_literal: true

require 'uri'
require 'net/http'

class RandomUserRequest
  attr_reader :host, :path, :results

  MAX_RESULTS = 5000

  def initialize(opts = {})
    @host = 'randomuser.me'
    @path = '/api'
    @results = opts.fetch(:results, MAX_RESULTS)
  end

  def call
    case response = Net::HTTP.get_response(uri)
    when Net::HTTPOK
      data = JSON.parse(response.body, symbolize_names: true)
      # randomuser.me may still return a 200 with a json object in the event the API is down. https://randomuser.me/documentation#errors
      raise Errors::ResponseError, data[:error] if data[:error].present?

      data
    else
      raise Errors::ResponseError, response
    end
  end

  private

  def uri
    @uri ||= URI::HTTPS.build host: host, path: path, query: query
  end

  def query
    { results: results,
      inc: %w[name email registered phone picture].join(',') }.to_param # include only the fields we care about: https://randomuser.me/documentation#incexc
  end
end
