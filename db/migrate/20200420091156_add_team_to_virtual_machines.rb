# frozen_string_literal: true

class AddTeamToVirtualMachines < ActiveRecord::Migration[6.0]
  def change
    add_reference :virtual_machines, :team, null: false, foreign_key: true
  end
end
