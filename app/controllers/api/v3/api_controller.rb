# frozen_string_literal: true

module API
  module V3
    class APIController < ::API::V2::APIController
      private
        def get_exercise
          @exercise = policy_scope(Exercise).friendly.find(params[:exercise_id])
        rescue ActiveRecord::RecordNotFound
          render_not_found
        end

        def render_not_found
          render_error(status: 404, message: 'Not found')
        end

        def render_error(status: 400, message:)
          render status: status, json: {
            error: {
              code: status,
              message: message
            }
          }
        end
    end
  end
end
