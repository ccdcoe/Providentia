# frozen_string_literal: true

class VirtualMachinesController < ApplicationController
  before_action :get_exercise
  before_action :get_virtual_machine, only: %i[update destroy]
  include VmPage # needs to be after other stuff
  skip_before_action :preload_form_collections, only: %i[index]

  respond_to :turbo_stream

  def index
    @virtual_machines = policy_scope(@exercise.virtual_machines)
      .preload(
        :team, :operating_system, :system_owner,
        :connection_nic, :exercise,
        network_interfaces: [
          { network: [:team, :exercise] }
        ]
      )
      .order(:name)

    filter_by_team
    filter_by_name
  end

  def new
    @virtual_machine = authorize(@exercise.virtual_machines.build)
  end

  def create
    @virtual_machine = @exercise.virtual_machines.build(
      params.require(:virtual_machine).permit(:name, :team_id)
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
          :team,
          :operating_system,
          networks: [:exercise],
          network_interfaces: [{ addresses: [:network] }, { network: [:team] }]
        )
      .find(params[:id])

    authorize @virtual_machine
  end

  def update
    @teams = policy_scope(Team).load_async
    @system_owners = policy_scope(User).order(:name).load_async
    @capabilities = policy_scope(@exercise.capabilities).load_async
    @services = policy_scope(@exercise.services).load_async

    @virtual_machine.update(virtual_machine_params)
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

    def filter_by_team
      return unless params[:team].present?
      team = policy_scope(Team).find_by(name: params[:team])
      @virtual_machines = @virtual_machines.where(team:)
    end

    def filter_by_name
      return unless params[:query].present?
      @virtual_machines = @virtual_machines.search(params[:query])
    end

    def virtual_machine_params
      params.require(:virtual_machine).permit(
        :name, :team_id, :bt_visible,
        :system_owner_id, :description,
        :deploy_mode, :custom_instance_count,
        :operating_system_id, :cpu, :ram, :primary_disk_size,
      )
    end
end
