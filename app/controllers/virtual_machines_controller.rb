# frozen_string_literal: true

class VirtualMachinesController < ApplicationController
  before_action :get_exercise
  before_action :get_virtual_machine, only: %i[update destroy]

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
          :capabilities,
          :services,
          :operating_system,
          networks: [:exercise],
          network_interfaces: [{ addresses: [:network] }, { network: [:team] }]
        )
      .find(params[:id])

    @teams = policy_scope(Team).load_async
    @system_owners = policy_scope(User).order(:name).load_async
    @capabilities = policy_scope(@exercise.capabilities).load_async
    @services = policy_scope(@exercise.services).load_async

    authorize @virtual_machine
  end

  def update
    @virtual_machine.update(update_params)
  end

  def destroy
    @virtual_machine.destroy
    redirect_to [@exercise, :virtual_machines], notice: 'Virtual machine was successfully destroyed.'
  end

  private
    def get_virtual_machine
      @virtual_machine = authorize(@exercise.virtual_machines.find(params[:id]))
    end

    def filter_by_team
      return unless params[:team].present?
      team = policy_scope(Team).find_by(name: params[:team])
      @virtual_machines = @virtual_machines.where(team: team)
    end

    def filter_by_name
      return unless params[:query].present?
      @virtual_machines = @virtual_machines.search(params[:query])
    end

    def virtual_machine_params
      params.require(:virtual_machine).permit(
        :name, :hostname, :role,
        :team_id, :bt_visible,
        :description, :deploy_mode, :custom_instance_count,
        :operating_system_id, :cpu, :ram, :primary_disk_size,
        :system_owner_id, { service_ids: [] }, { capability_ids: [] }
      )
    end

    def update_params
      if current_user.admin? || !@virtual_machine.exercise.services_read_only
        virtual_machine_params
      else
        virtual_machine_params.tap do |params|
          params.delete(:service_ids)
        end
      end
    end
end
