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
      color = network_interface.network&.team&.ui_color || 'gray'
      case color
      when 'yellow'
        "bg-#{color}-200 text-#{color}-800 dark:bg-#{color}-500 dark:text-#{color}-700"
      else
        "bg-#{color}-200 text-#{color}-800 dark:bg-#{color}-700 dark:text-#{color}-300"
      end
    end

    def egress_toggle_text
      if network_interface.egress?
        'Remove egress'
      else
        'Mark egress'
      end
    end
end
