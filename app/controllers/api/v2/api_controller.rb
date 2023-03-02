# frozen_string_literal: true

module API
  module V2
    class APIController < ActionController::API
      include Pundit::Authorization

      before_action :set_sentry_context, :skip_trackable, :authenticate_request

      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

      private
        def set_sentry_context
          Sentry.set_user(id: current_user&.id)
          Sentry.set_extras(params: params.to_unsafe_h, url: request.url)
        end

        def skip_trackable
          request.env['warden'].request.env['devise.skip_trackable'] = '1'
        end

        def token_value
          request.headers['Authorization']&.sub(/(Token|Bearer) /, '')
        end

        def authenticate_request
          user = authenticate_by_local_token || authenticate_by_access_token
          return render json: { error: 'Unauthenticated' }, status: 401 unless user

          sign_in user
        end

        def authenticate_by_local_token
          APIToken.find_by_token(token_value)&.user
        end

        def authenticate_by_access_token
          APIVerifyService.call(token_value).result
        end

        def pundit_user
          UserContext.new(current_user, @exercise)
        end

        def user_not_authorized
          render json: { error: 'You are not authorized to perform this action.' }, status: 403
        end
    end
  end
end
