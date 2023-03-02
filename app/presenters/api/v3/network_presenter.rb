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
            team: network.team.name.downcase,
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
          if network.numbered?
            1.upto(network.exercise.last_dev_bt).to_a
          else
            [nil]
          end
        end
    end
  end
end
