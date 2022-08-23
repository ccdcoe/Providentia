# frozen_string_literal: true

class AddNumberingToVirtualMachines < ActiveRecord::Migration[6.0]
  def change
    add_column :virtual_machines, :deploy_mode, :integer, default: 0, null: false
    add_column :virtual_machines, :custom_instance_count, :integer
  end
end
