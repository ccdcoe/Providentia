# frozen_string_literal: true

class NetworkInterfaceFormComponent < ViewComponent::Base
  with_collection_parameter :network_interface

  attr_reader :network_interface, :network_interface_counter

  def initialize(network_interface:, network_interface_counter:)
    @network_interface = network_interface
    @network_interface_counter = network_interface_counter
  end

  private
    def networks
      network_interface.exercise.networks
    end

    def team_classes
      helpers.actor_color_classes(network_interface.network&.actor)
    end

    def egress_toggle_text
      if network_interface.egress?
        'Remove egress'
      else
        'Mark egress'
      end
    end
end
