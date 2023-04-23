# frozen_string_literal: true

class ServiceSubjectsController < ApplicationController
  before_action :get_exercise, :get_service

  respond_to :turbo_stream

  def create
    @subject = @service.service_subjects.create
  end

  private
    def get_service
      @service = policy_scope(@exercise.services).friendly.find(params[:service_id])
    end
end
