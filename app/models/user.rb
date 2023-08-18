# frozen_string_literal: true

class User < ApplicationRecord
  validates :registered_at, uniqueness: true
end
