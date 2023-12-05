# frozen_string_literal: true

module VmCacheBuster
  extend ActiveSupport::Concern

  included do
    around_destroy :update_specs_before
    around_save :update_specs_before
  end

  private
    def update_specs_before
      spec_ids = Set.new
      spec_ids.merge(get_service.cached_spec_ids)
      yield
      spec_ids.merge(get_service.cached_spec_ids)
      update_specs(spec_ids)
    end

    def update_specs_after
      update_specs(get_service.cached_spec_ids)
    end

    def update_specs(ids)
      exercise.customization_specs.where(id: ids).touch_all
    end

    def get_service
      case self
      when Service
        self
      else
        service
      end.tap { |s| s.reload if s.persisted? }
    end
end
