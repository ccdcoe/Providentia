# frozen_string_literal: true

class SpecialChecksController < ApplicationController
  before_action :get_exercise, :get_service
  before_action :get_check, only: %i[update destroy]

  respond_to :turbo_stream

  def create
    @check = @service.special_checks.create(check_params)
  end

  def update
    @check.update(check_params)
  end

  def destroy
    @check.destroy
  end

  private
    def check_params
      params.fetch(:special_check, {}).permit(:network_id, :name, :scored)
    end

    def get_service
      @service = policy_scope(@exercise.services).find(params[:service_id])
    end

    def get_check
      @check = authorize(@service.special_checks.find(params[:id]))
    end
end
