# frozen_string_literal: true

class ConditionsController < ApplicationController
  before_action :get_exercise, :get_service, :get_subject
  before_action :get_condition, only: %i[update destroy]

  respond_to :turbo_stream

  def self.controller_path
    'service_subject_match_conditions'
  end

  def create
    @condition = ServiceSubjectMatchCondition.new(matcher_type: nil, matcher_id: nil)
    @subject.match_conditions << @condition
    @subject.save
  end

  def update
    if @condition
      @condition.attributes = subject_params.to_h
      @subject.save
    end
  end

  def destroy
    if @condition
      @subject.match_conditions.delete(@condition)
      if @subject.match_conditions.empty? # last matcher, remove subject
        @subject.destroy
      else
        @subject.save
      end
    end
  end

  private
    def subject_params
      params.require(:service_subject_match_condition).permit(
        :matcher_id, :matcher_type
      )
    end

    def get_service
      @service = policy_scope(@exercise.services).friendly.find(params[:service_id])
    end

    def get_subject
      @subject = authorize(@service.service_subjects.find(params[:service_subject_id]))
    end

    def get_condition
      @condition = @subject
        .match_conditions
        .detect { |condition| condition.id == params[:id] }
    end
end
