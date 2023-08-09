# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    @exercises = policy_scope(Exercise).order(:name) if params[:archived]
    @exercises = @exercises.includes(:services)

    @my_exercises, @other_exercises = @exercises.partition do |ex|
      ex.virtual_machines.where(system_owner: current_user).exists?
    end
  end
end
