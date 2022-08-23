# frozen_string_literal: true

class AddOperatingSystemToVirtualMachine < ActiveRecord::Migration[6.0]
  def change
    add_reference :virtual_machines, :operating_system, null: true, foreign_key: true
  end
end
