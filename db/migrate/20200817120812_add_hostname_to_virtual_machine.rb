# frozen_string_literal: true

class AddHostnameToVirtualMachine < ActiveRecord::Migration[6.0]
  def change
    add_column :virtual_machines, :hostname, :string
  end
end
