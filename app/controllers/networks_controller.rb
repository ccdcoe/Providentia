# frozen_string_literal: true

class NetworksController < ApplicationController
  before_action :get_exercise
  before_action :get_network, only: %i[show edit update destroy]

  def index
    @networks = policy_scope(@exercise.networks).order(:name).includes(:team, :address_pools)
  end

  def new
    @network = authorize(@exercise.networks.build)
  end

  def create
    @network = @exercise.networks.build(network_params)

    if @network.valid? && authorize(@network).save
      redirect_to [:edit, @network.exercise, @network], notice: 'Network was successfully created.'
    else
      render :new, status: 400
    end
  end

  def show; end

  def update
    if @network.update network_params
      redirect_to [:edit, @network.exercise, @network], notice: 'Network was successfully updated.'
    else
      render :edit, status: 400
    end
  end

  def destroy
    if @network.destroy
      redirect_to [@exercise, :networks], notice: 'Network was successfully destroyed.'
    else
      redirect_to [@exercise, :networks], flash: { error: @network.errors.full_messages.join(', ') }
    end
  end

  private
    def network_params
      params.require(:network).permit(
        :name, :team_id, :cloud_id, :domain, :abbreviation, :description,
        :ignore_root_domain, { capability_ids: [] }
      )
    end

    def get_network
      @network = authorize(@exercise.networks.friendly.find(params[:id]))
    end
end
