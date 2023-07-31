# frozen_string_literal: true

module API
  module V3
    class ActorsController < APIController
      before_action :get_exercise

      def index
        actors = policy_scope(@exercise.actors)
        render json: {
          result: actors.arrange_serializable { |parent, children| ActorPresenter.new(parent, children) }
        }
      end
    end
  end
end
