# frozen_string_literal: true

module API
  module V3
    class CapabilityPresenter < Struct.new(:capability)
      def as_json(_opts)
        Rails.cache.fetch(['apiv3', capability]) do
          {
            id: capability.slug,
            description: capability.description,
            virtual_machines: capability.virtual_machines.pluck(:name),
            networks: capability.networks.pluck(:name)
          }
        end
      end
    end
  end
end
