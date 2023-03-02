# frozen_string_literal: true

class AddressesController < ApplicationController
  before_action :get_exercise, :get_network_interface
  before_action :preload_forms
  before_action :get_address, only: %i[update destroy]

  include VmPage # needs to be after other stuff

  respond_to :turbo_stream

  def create
    authorize @network_interface, :update?
    @address = @network_interface.addresses.create
  end

  def update
    @address.update(address_params)
  end

  def destroy
    @address.destroy
  end

  private
    def address_params
      params.require(:address).permit(
        :mode, :address_pool_id, :offset, :offset_address, :dns_enabled, :parsed_ipv6,
        :connection
      )
    end

    def get_network_interface
      @network_interface = policy_scope(@exercise.virtual_machines)
        .find(params[:virtual_machine_id])
        .network_interfaces
        .find(params[:network_interface_id])
    end

    def get_address
      @address = authorize(@network_interface.addresses.find(params[:id]))
    end

    def preload_forms
      @capabilities = policy_scope(@exercise.capabilities).load_async
      @services = policy_scope(@exercise.services).load_async
    end
end
