# frozen_string_literal: true

class AddBtVisibilityToVirtualMachines < ActiveRecord::Migration[6.1]
  def change
    add_column :virtual_machines, :bt_visible, :boolean, null: false, default: true
  end
end
