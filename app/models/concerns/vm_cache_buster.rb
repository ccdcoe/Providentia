# frozen_string_literal: true

module VmCacheBuster
  extend ActiveSupport::Concern

  included do
    before_destroy :update_specs
    after_save :update_specs
  end

  private
    def update_specs
      l_service = case self
                  when Service
                    self
                  else
                    service
      end
      exercise
        .customization_specs
        .where(id: l_service.cached_spec_ids)
        .touch_all
    end
end
