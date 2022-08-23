# frozen_string_literal: true

module API
  module V3
    class ExercisePresenter < Struct.new(:exercise)
      def as_json(_opts)
        Rails.cache.fetch(['apiv3', exercise]) do
          {
            id: exercise.slug,
            name: exercise.name,
            description: exercise.description,
            teams: {
              blue: exercise.all_blue_teams,
              blue_dev: exercise.dev_blue_teams,
            }
          }
        end
      end
    end
  end
end
