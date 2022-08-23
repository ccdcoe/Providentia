# frozen_string_literal: true

class AddSystemOwnerToVirtualMachines < ActiveRecord::Migration[6.0]
  def change
    add_column :virtual_machines, :system_owner_id, :integer
    add_foreign_key :virtual_machines, :users, column: :system_owner_id
  end
end
