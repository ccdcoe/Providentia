# frozen_string_literal: true

class ActorNumberConfig < ApplicationRecord
  belongs_to :actor, touch: true
end
