# frozen_string_literal: true

class CapabilitiesController < ApplicationController
  before_action :get_exercise
  before_action :get_capability, only: %i[show edit update destroy]

  def index
    @capabilities = policy_scope(@exercise.capabilities).order(:name)
  end

  def new
    @capability = authorize(@exercise.capabilities.build)
  end

  def create
    @capability = @exercise.capabilities.build(capability_params)

    if @capability.valid? && authorize(@capability).save
      redirect_to [@capability.exercise, @capability], notice: 'Capability was successfully created.'
    else
      render :new, status: 400
    end
  end

  def show; end

  def update
    if @capability.update capability_params
      redirect_to [@capability.exercise, @capability], notice: 'Capability was successfully updated.'
    else
      render :show, status: 400
    end
  end

  def destroy
    if @capability.destroy
      redirect_to [@exercise, :capabilities], notice: 'Capability was successfully destroyed.'
    else
      redirect_to [@exercise, :capabilities], flash: { error: @capability.errors.full_messages.join(', ') }
    end
  end

  private
    def capability_params
      params.require(:capability).permit(:name, :description)
    end

    def get_capability
      @capability = authorize(@exercise.capabilities.friendly.find(params[:id]))
    end
end
