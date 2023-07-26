# frozen_string_literal: true

module API
  module V3
    class NetworkPresenter < Struct.new(:network)
      def as_json(_opts)
        Rails.cache.fetch(['apiv3', network.cache_key_with_version]) do
          {
            id: network.slug,
            name: network.name,
            description: network.description,
            actor: network.actor.abbreviation.downcase,
            instances:
          }
        end
      end

      private
        def instances
          instance_generator
            .map { |team_number| NetworkInstancePresenter.new(network, team_number) }
            .map(&:as_json)
        end

        def instance_generator
          return [nil] unless network.numbered?
          numbering_source
        end

        def numbering_source
          if network.actor.number?
            network.actor.all_numbers
          end
        end
    end
  end
end
