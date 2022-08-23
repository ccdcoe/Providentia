# frozen_string_literal: true

module API
  module V3
    class ServicePresenter < Struct.new(:service)
      def as_json(_opts)
        Rails.cache.fetch(['apiv3', service]) do
          {
            id: service.name,
            checks: network_checks + special_checks
          }
        end
      end

      private
        def network_checks
          service.service_checks.flat_map(&:virtual_checks).map do |check|
            {
              id: check.slug,
              source_network_id: check.network.slug,
              protocol: check.protocol,
              ip: check.ip_family,
              port: check.destination_port
            }
          end
        end

        def special_checks
          service.special_checks.map do |check|
            {
              id: check.slug,
              source_network_id: check.network.slug,
              name: check.name,
              special: true
            }
          end
        end
    end
  end
end
