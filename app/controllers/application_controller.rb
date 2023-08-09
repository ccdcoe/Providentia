# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :load_exercises, :set_sentry_context,
    :authenticate_user!, :set_paper_trail_whodunnit

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :user_not_authorized

  private
    def load_exercises
      @exercises = policy_scope(Exercise).active.order(:name)
    end

    def set_sentry_context
      Sentry.set_user(id: current_user&.id, exercise: session[:exercise_id])
      Sentry.set_extras(params: params.to_unsafe_h, url: request.url)
    end

    def get_exercise
      @exercise = policy_scope(Exercise).friendly.find(params[:exercise_id])
    end

    def pundit_user
      UserContext.new(current_user, @exercise)
    end

    def user_not_authorized
      flash[:error] = 'You are not authorized to perform this action.'
      redirect_back fallback_location: root_path
    end
end
