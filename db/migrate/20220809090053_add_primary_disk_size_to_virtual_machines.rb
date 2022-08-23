# frozen_string_literal: true

class AddPrimaryDiskSizeToVirtualMachines < ActiveRecord::Migration[7.0]
  def change
    add_column :virtual_machines, :primary_disk_size, :integer
  end
end
