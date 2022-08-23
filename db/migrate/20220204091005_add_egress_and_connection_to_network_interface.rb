# frozen_string_literal: true

class AddEgressAndConnectionToNetworkInterface < ActiveRecord::Migration[7.0]
  def change
    add_column :network_interfaces, :egress, :boolean, null: false, default: false
    add_column :network_interfaces, :connection, :boolean, null: false, default: false

    VirtualMachine.find_each do |vm|
      next unless vm.network_interfaces.any?
      vm.network_interfaces.first.update(connection: true, egress: true)
    end
  end
end
