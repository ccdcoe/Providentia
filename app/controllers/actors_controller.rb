# frozen_string_literal: true

class ActorsController < ApplicationController
  before_action :get_exercise
  before_action :get_actor, except: %i[create]

  respond_to :turbo_stream

  def create
    authorize @exercise.actors, :create?
    new_actor_params = {
      name: 'New actor',
      abbreviation: 'na'
    }
    if params[:actor_id]
      parent = policy_scope(@exercise.actors).find(params[:actor_id])
      new_actor_params[:parent] = parent
    end
    @actor = @exercise.actors.create(new_actor_params)
  end

  def show
    authorize @actor, :update?
  end

  def update
    authorize @actor, :update?
    @actor.update(actor_params)
  end

  def destroy
    authorize @actor
    @actor.destroy
  end

  private
    def get_actor
      @actor = policy_scope(@exercise.actors).find(params[:id])
    end

    def actor_params
      params.require(:actor).permit(
        :name, :abbreviation, :description, :number,
        :parent_id
      )
    end
end
