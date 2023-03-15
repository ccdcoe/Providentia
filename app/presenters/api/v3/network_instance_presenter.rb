# frozen_string_literal: true

module API
  module V3
    class NetworkInstancePresenter < Struct.new(:network, :team_number)
      def as_json
        {
          team_nr: team_number,
          cloud_id: substitute(network.cloud_id),
          domains: [
            substitute(network.full_domain)
          ].reject(&:blank?),
          address_pools: network.address_pools.map do |pool|
            {
              id: pool.slug,
              ip_family: pool.ip_family,
              network_address: substitute(pool.network_address),
              gateway: pool.gateway_address_object&.ip_object(nil, team_number)&.to_s
            }
          end,
          config_map: network.config_map&.deep_transform_values do |value|
            value.is_a?(String) ? substitute(value) : value
          end
        }
      end

        private
          def substitute(text)
            StringSubstituter.result_for(
              text,
              {
                team_nr: team_number
              }
            )
          end
    end
  end
end
