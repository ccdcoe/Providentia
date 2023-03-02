# frozen_string_literal: true

class AddVisibilityToVirtualMachines < ActiveRecord::Migration[7.0]
  def change
    add_column :virtual_machines, :visibility, :integer, default: 1
  end
end
