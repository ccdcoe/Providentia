# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    @exercises = policy_scope(Exercise).order(:name) if params[:archived]
    @exercises = @exercises.includes(:services)
  end
end
