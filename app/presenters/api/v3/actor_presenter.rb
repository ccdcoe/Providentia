# frozen_string_literal: true

module API
  module V3
    class ActorPresenter < Struct.new(:actor, :children)
      def as_json(_opts = nil)
        Rails.cache.fetch(['apiv3', actor.cache_key_with_version, actor.actor_number_configs.cache_key_with_version]) do
          {
            id: ActorAPIName.result_for(actor),
            name: actor.name,
            instances:,
            config_map: actor.prefs,
            children: children.map(&:as_json)
          }
        end
      end

      private
        def instances
          return [] if !actor.root.number?
          actor.root.all_numbers
            .map { |number| ActorInstancePresenter.new(actor, number) }
            .map(&:as_json)
        end
    end
  end
end
