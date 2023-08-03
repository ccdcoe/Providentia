# frozen_string_literal: true

class VirtualMachinesController < ApplicationController
  include VmPage
  before_action :get_exercise
  before_action :get_virtual_machine, only: %i[update destroy]
  before_action :preload_form_collections, only: %i[new create show destroy]

  respond_to :turbo_stream

  def index
    @virtual_machines = policy_scope(@exercise.virtual_machines)
      .preload(
        :actor, :operating_system, :system_owner,
        :connection_nic, :exercise,
        network_interfaces: [
          { network: [:actor, :exercise] }
        ]
      )
      .order(:name)

    filter_by_actor
    filter_by_name
  end

  def new
    @virtual_machine = authorize(@exercise.virtual_machines.build)
  end

  def create
    @virtual_machine = @exercise.virtual_machines.build(
      params.require(:virtual_machine).permit(:name, :actor_id)
    )

    if @virtual_machine.valid? && authorize(@virtual_machine).save
      redirect_to [@exercise, @virtual_machine], notice: 'Virtual machine was successfully created.'
    else
      render :new, status: 400
    end
  end

  def show
    @virtual_machine ||= @exercise
      .virtual_machines
      .includes(
          :actor,
          :operating_system,
          networks: [:exercise],
          network_interfaces: [{ addresses: [:network] }, { network: [:actor] }]
        )
      .find(params[:id])

    preload_services
    authorize @virtual_machine
  end

  def update
    @virtual_machine.numbered_by = get_numbered
    @virtual_machine.assign_attributes(virtual_machine_params)
    @virtual_machine.save

    preload_services
    preload_form_collections
  end

  def destroy
    @virtual_machine.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to [@exercise, :virtual_machines], notice: 'Virtual machine was successfully destroyed.' }
    end
  end

  private
    def get_virtual_machine
      @virtual_machine = authorize(@exercise.virtual_machines.find(params[:id]))
    end

    def filter_by_actor
      return unless params[:actor].present?
      @filter_actor = policy_scope(@exercise.actors).find_by(abbreviation: params[:actor])
      @virtual_machines = @virtual_machines.where(actor: @filter_actor)
    end

    def filter_by_name
      return unless params[:query].present?
      @virtual_machines = @virtual_machines.search(params[:query])
    end

    def virtual_machine_params
      params.require(:virtual_machine).permit(
        :name, :actor_id, :visibility,
        :system_owner_id, :description,
        :custom_instance_count,
        :operating_system_id, :cpu, :ram, :primary_disk_size,
      )
    end

    def get_numbered
      authorize(
        GlobalID::Locator.locate(
          params[:virtual_machine].extract!(:numbered_by)[:numbered_by]
        ),
        :show?
      )
    end
end
