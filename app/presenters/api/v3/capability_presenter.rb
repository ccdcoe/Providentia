# frozen_string_literal: true

module API
  module V3
    class CapabilityPresenter < Struct.new(:capability)
      def as_json(_opts)
        Rails.cache.fetch(['apiv3', capability.cache_key_with_version]) do
          {
            id: capability.slug,
            name: capability.name,
            description: capability.description,
            virtual_machines: capability.customization_specs.pluck(:slug)
          }
        end
      end
    end
  end
end
