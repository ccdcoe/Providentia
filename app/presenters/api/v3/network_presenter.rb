# frozen_string_literal: true

module API
  module V3
    class NetworkPresenter < Struct.new(:network)
      def as_json(_opts)
        Rails.cache.fetch(['apiv3', network]) do
          {
            id: network.slug,
            name: network.name,
            description: network.description,
            cloud_id: network.cloud_id,
            team: network.team.name.downcase,
            address_pools: network.address_pools.map do |pool|
              {
                id: pool.slug,
                ip_family: pool.ip_family,
                network_address: pool.network_address,
                gateway:  UnsubstitutedAddress.result_for(pool.gateway_address_object)
              }
            end
          }
        end
      end
    end
  end
end
