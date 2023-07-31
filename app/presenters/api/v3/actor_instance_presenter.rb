# frozen_string_literal: true

module API
  module V3
    class ActorInstancePresenter < Struct.new(:actor, :number)
      def as_json
        {
          number:,
          config_map: configs.map(&:config_map).reduce(&:merge) || {}
        }
      end

      private
        def configs
          actor
            .actor_number_configs
            .where('matcher @> :nr::jsonb', nr: [number.to_s].to_json)
        end
    end
  end
end
