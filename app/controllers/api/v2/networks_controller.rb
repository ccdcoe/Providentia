# frozen_string_literal: true

module API
  module V2
    class NetworksController < APIController
      helper :api
      before_action :get_exercise

      def show
        authorize @exercise
      end

      private
        def get_exercise
          @exercise = Exercise.find_by(abbreviation: params[:exercise_id])
        end
    end
  end
end
