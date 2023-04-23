# frozen_string_literal: true

module API
  module V3
    class ServicePresenter < Struct.new(:service, :spec_scope)
      def as_json(_opts)
        Rails.cache.fetch(['apiv3', service.cache_key_with_version]) do
          {
            id: service.slug,
            name: service.name,
            subjects:,
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
              scored: check.scored,
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
              source_network_id: check.network&.slug,
              scored: check.scored,
              name: check.name,
              special: true
            }
          end
        end

        def subjects
          spec_scope
            .where(id: service.cached_spec_ids)
            .order(:slug)
            .pluck(:slug) || []
        end
    end
  end
end
