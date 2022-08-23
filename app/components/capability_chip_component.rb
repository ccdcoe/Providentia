# frozen_string_literal: true

class CapabilityChipComponent < ViewComponent::Base
  with_collection_parameter :name

  def initialize(name:)
    @name = name
  end
end
