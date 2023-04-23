# frozen_string_literal: true

class CustomizationSpecsController < ApplicationController
  include VmPage
  before_action :get_exercise, :get_virtual_machine
  before_action :preload_form_collections, only: %i[create update]
  before_action :get_customization_spec, only: %i[update destroy]

  respond_to :turbo_stream

  def create
    authorize @virtual_machine, :update?
    @customization_spec = @virtual_machine
      .customization_specs
      .create(mode: 'container', name: "spec-#{@virtual_machine.customization_specs.size}")
  end

  def update
    preload_services
    @customization_spec.update(spec_params)
  end

  def destroy
    @customization_spec.destroy unless @customization_spec.mode_host?
  end

  private
    def get_virtual_machine
      @virtual_machine = policy_scope(@exercise.virtual_machines)
        .find(params[:virtual_machine_id])
    end

    def get_customization_spec
      @customization_spec = authorize(@virtual_machine.customization_specs.friendly.find(params[:id]))
    end

    def spec_params
      params.require(:customization_spec).permit(
        :name, :dns_name, :role_name, :description,
        { service_ids: [] }, { capability_ids: [] }
      )
    end
end
