# frozen_string_literal: true

class AddHardwareToOperatingSystems < ActiveRecord::Migration[7.0]
  def change
    add_column :operating_systems, :cpu, :integer
    add_column :operating_systems, :ram, :integer
    add_column :operating_systems, :primary_disk_size, :integer
  end
end
