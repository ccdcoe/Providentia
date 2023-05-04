# frozen_string_literal: true

class ChecksController < ApplicationController
  before_action :get_exercise, :get_service
  before_action :get_check, only: %i[update destroy]
  include ServicePage

  respond_to :turbo_stream

  def create
    self_subject = CustomCheckSubject.find_by(base_class: 'CustomizationSpec', meaning: 'self')
    @check = @service.checks.create({
      source: self_subject,
      destination: self_subject
    })
  end

  def update
    if params[:cm]
      config_map_update
    else
      regular_update
    end
  end

  def destroy
    @check.destroy
  end

  private
    def check_params
      params.fetch(:check, {}).permit(
        :check_mode,
        :special_label,  :protocol, :ip_family, :port, :scored
      )
    end

    def get_service
      @service = policy_scope(@exercise.services)
        .includes(:service_subjects)
        .friendly
        .find(params[:service_id])
    end

    def get_check
      @check = authorize(@service.checks.find(params[:id]))
    end

    def get_directions
      filtered_params = params[:check].extract!(:source_gid, :destination_gid)
      [
        authorize(
          GlobalID::Locator.locate(filtered_params[:source_gid]),
          :show?
        ),
        authorize(
          GlobalID::Locator.locate(filtered_params[:destination_gid]),
          :show?
        )
      ]
    end

    def config_map_update
      @form = ConfigMapForm.new(@check, params[:cm])
      if @form.save
        render turbo_stream: turbo_stream.remove('config_map_errors')
      else
        render turbo_stream: turbo_stream.append(
          'config_map_form',
          FormErrorBoxComponent.new(@form, id: 'config_map_errors').render_in(view_context)
        )
      end
    end

    def regular_update
      @check.assign_attributes(check_params)
      source, destination = get_directions
      @check.source = source
      @check.destination = destination
      @check.save
    end
end
