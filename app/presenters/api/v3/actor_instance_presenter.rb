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
            .for_number(number)
        end
    end
  end
end
