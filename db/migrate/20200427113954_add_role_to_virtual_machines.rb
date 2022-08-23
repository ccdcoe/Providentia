# frozen_string_literal: true

class AddRoleToVirtualMachines < ActiveRecord::Migration[6.0]
  def change
    add_column :virtual_machines, :role, :string
  end
end
