# frozen_string_literal: true

class OperatingSystemsController < ApplicationController
  before_action :get_operating_system, only: %i[show update destroy]
  before_action :load_arranged_operating_systems, except: %i[destroy]

  def index
  end

  def new
    @operating_system = OperatingSystem.new
    authorize @operating_system
  end

  def create
    @operating_system = OperatingSystem.new(operating_system_params)
    authorize @operating_system

    if @operating_system.save
      redirect_to operating_systems_path, flash: { notice: "#{OperatingSystem.model_name.human} was successfully created." }
    else
      render :new, status: 400
    end
  end

  def show
    @merge = MergeOsForm.new(source_id: @operating_system.id)
  end

  def update
    if @operating_system.update operating_system_params
      redirect_to operating_systems_path, flash: { notice: "#{OperatingSystem.model_name.human} was successfully updated." }
    else
      render :show, status: 400
    end
  end

  def destroy; end

  def merge
    @merge = MergeOsForm.new(params[:merge_os])
    if @merge.save
      redirect_to operating_systems_path, flash: { notice: "OS #{@merge.source_id} merged into #{@merge.destination_id}!" }
    else
      @operating_system ||= OperatingSystem.find(@merge.source_id)
      render :show, status: 400
    end
  end

  private
    def get_operating_system
      @operating_system = OperatingSystem.friendly.find(params[:id])
      authorize @operating_system
    end

    def load_arranged_operating_systems
      @operating_systems = OrderedOperatingSystems.result_for(policy_scope(OperatingSystem))
    end

    def operating_system_params
      params.require(:operating_system).permit(:name, :parent_id, :cpu, :ram, :primary_disk_size)
    end
end
