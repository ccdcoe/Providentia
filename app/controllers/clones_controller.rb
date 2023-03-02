# frozen_string_literal: true

class ClonesController < ApplicationController
  before_action :get_exercise

  def show
    @clone = CloneExerciseForm.new(exercise_id: @exercise.id)
  end

  def create
    authorize @exercise, :create?
    @clone = CloneExerciseForm.new(params[:clone])
    @clone.exercise_id = @exercise.id

    if @clone.save
      redirect_to root_path, flash: { notice: "Environment #{@exercise.name} cloned to #{@clone.name}!" }
    else
      render :show, status: 400
    end
  end
end
