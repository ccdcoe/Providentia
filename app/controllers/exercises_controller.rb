# frozen_string_literal: true

class ExercisesController < ApplicationController
  before_action :get_exercise, :load_actors, only: %i[show edit update]

  def new
    @exercise = Exercise.new
    authorize @exercise
  end

  def create
    @exercise = Exercise.new(exercise_params)
    authorize @exercise

    if @exercise.save
      redirect_to @exercise, notice: 'Exercise was successfully created.'
    else
      render :new, status: 400
    end
  end

  def show
    authorize @exercise
  end

  def edit
    authorize @exercise
  end

  def update
    authorize @exercise
    if @exercise.update exercise_params
      redirect_to @exercise, notice: 'Exercise was successfully updated.'
    else
      render :edit, status: 400
    end
  end

  private
    def get_exercise
      @exercise = Exercise.friendly.find(params[:id])
    end

    def load_actors
      @actors = OrderedTree.result_for(policy_scope(@exercise.actors))
    end

    def exercise_params
      params.require(:exercise).permit(:name, :abbreviation,
        :dev_resource_name, :dev_red_resource_name, :local_admin_resource_name,
        :services_read_only,
        :root_domain,
        :archived,
        :description
      )
    end
end
