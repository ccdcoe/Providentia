# frozen_string_literal: true

module API
  module V3
    class ExercisesController < APIController
      def index
        render json: {
          result: policy_scope(Exercise).map do |ex|
            {
              id: ex.slug,
              name: ex.name
            }
          end
        }
      end

      def show
        exercise = policy_scope(Exercise).friendly.find(params[:id])

        render json: { result: ExercisePresenter.new(exercise) }
      rescue ActiveRecord::RecordNotFound
        render_not_found
      end
    end
  end
end
