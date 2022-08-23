# frozen_string_literal: true

class AddHardwareToVirtualMachine < ActiveRecord::Migration[6.0]
  def change
    add_column :virtual_machines, :cpu, :integer
    add_column :virtual_machines, :ram, :integer
  end
end
