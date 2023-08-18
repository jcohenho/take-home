# frozen_string_literal: true

module Errors
  class LimitRangeError < StandardError
    def message
      'Limit must be between 1 and 100.'
    end
  end
end
