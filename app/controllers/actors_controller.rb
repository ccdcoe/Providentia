# frozen_string_literal: true

class ActorsController < ApplicationController
  before_action :get_exercise, :get_actor

  respond_to :turbo_stream

  def edit
    authorize @exercise, :update?
    @form = ActorNumberingForm.new(@actor)
    render partial: 'actors/numbering/edit', locals: { actor: @actor }
  end

  def update
    authorize @exercise, :update?
    ActorNumberingForm.new(@actor, params[:numbering]).save
    @actor.reload
    render partial: 'actors/numbering/show', locals: { actor: @actor }
  end

  private
    def get_actor
      @actor = @exercise.actors.find(params[:id])
    end
end
