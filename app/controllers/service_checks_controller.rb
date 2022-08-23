# frozen_string_literal: true

class ServiceChecksController < ApplicationController
  before_action :get_exercise, :get_service
  before_action :get_check, only: %i[update destroy]

  respond_to :turbo_stream

  def create
    @check = @service.service_checks.create(check_params)
  end

  def update
    @check.update(check_params)
  end

  def destroy
    @check.destroy
  end

  private
    def check_params
      params.fetch(:service_check, {}).permit(
        :network_id, :protocol, :ip_family, :destination_port
      )
    end

    def get_service
      @service = policy_scope(@exercise.services).find(params[:service_id])
    end

    def get_check
      @check = authorize(@service.service_checks.find(params[:id]))
    end
end
