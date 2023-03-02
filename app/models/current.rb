# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :interfaces_cache, :services_cache
end
