# frozen_string_literal: true

class NetworkInterfacesController < ApplicationController
  before_action :get_exercise, :get_virtual_machine
  before_action :preload_forms
  before_action :get_network_interface, only: %i[destroy update]

  include VmPage # needs to be after other stuff

  respond_to :turbo_stream

  def new
    @network_interface = authorize(@virtual_machine.network_interfaces.build)
  end

  def create
    @network_interface = authorize(@virtual_machine.network_interfaces.build(nic_params), :create?)
    @network_interface.save
  end

  def destroy
    @network_interface.destroy
  end

  def update
    @network_interface.update(nic_params)
  end

  private
    def nic_params
      params.require(:network_interface).permit(
        :network_id, :egress
      )
    end

    def get_virtual_machine
      @virtual_machine = @exercise.virtual_machines.find(params[:virtual_machine_id])
      authorize @virtual_machine
    end

    def get_network_interface
      @network_interface = @virtual_machine.network_interfaces.find(params[:id])
      authorize @network_interface
    end

    def preload_forms
      @capabilities = policy_scope(@exercise.capabilities).load_async
      @services = policy_scope(@exercise.services).load_async
    end
end
