# frozen_string_literal: true

module VmCacheBuster
  extend ActiveSupport::Concern

  included do
    before_destroy :update_specs
    after_save :update_specs
  end

  private
    def update_specs
      customization_specs.touch_all
    end
end
