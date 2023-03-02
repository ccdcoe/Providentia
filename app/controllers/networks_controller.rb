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

  def edit
    @form = ConfigMapForm.new(@network)
  end

  def update
    if params[:cm]
      config_map_update
    else
      regular_update
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

    def config_map_update
      @form = ConfigMapForm.new(@network, params[:cm])
      if @form.save
        render turbo_stream: turbo_stream.remove('config_map_errors')
      else
        render turbo_stream: turbo_stream.append(
          'config_map_form',
          FormErrorBoxComponent.new(@form, id: 'config_map_errors').render_in(view_context)
        )
      end
    end

    def regular_update
      if @network.update network_params
        redirect_to [:edit, @network.exercise, @network], notice: 'Network was successfully updated.'
      else
        render :edit, status: 400
      end
    end
end
