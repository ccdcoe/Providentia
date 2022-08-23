# frozen_string_literal: true

class APIToken < ApplicationRecord
  belongs_to :user
  has_secure_token

  def self.to_icon
    'fa-key'
  end
end
