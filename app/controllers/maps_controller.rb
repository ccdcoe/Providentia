# frozen_string_literal: true

class MapsController < ApplicationController
  before_action :get_exercise

  def show
    respond_to do |format|
      format.json {
        render json: {
          result: Rails.cache.fetch([vm_scope, 'network_map_api', params[:full_map].present?]) do
            NetworkMapGraphSerializer.result_for(graph)
          end
        }
      }
      format.html
    end
  end

  private
    def vm_scope
      policy_scope(@exercise.virtual_machines)
        .includes(connection_nic: [{ network: [:team] }, :virtual_machine])
        .includes(:team)
    end

    def graph
      ExerciseGraphGenerator.result_for(
        vm_scope,
        {
          skip_single_hop_networks: true,
          full_map: params[:full_map].present?
        }
      )
    end
end
