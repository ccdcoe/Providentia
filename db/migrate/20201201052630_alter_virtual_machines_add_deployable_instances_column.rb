# frozen_string_literal: true

class AlterVirtualMachinesAddDeployableInstancesColumn < ActiveRecord::Migration[6.0]
  def up
    add_column :virtual_machines, :generated_deployable_instances, :json, default: {}

    VirtualMachine.all.map(&:generate_deployable_instances)
  end

  def down
    remove_column :virtual_machines, :generated_deployable_instances
  end
end
