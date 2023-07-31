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
            .map { |actor_number| NetworkInstancePresenter.new(network, actor_number) }
            .map(&:as_json)
        end

        def instance_generator
          numbering_source || [nil]
        end

        def numbering_source
          network.actor.root.all_numbers if network.numbered? && network.actor.root.number?
        end
    end
  end
end
