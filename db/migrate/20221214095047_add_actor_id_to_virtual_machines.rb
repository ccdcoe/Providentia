# frozen_string_literal: true

class AddActorIdToVirtualMachines < ActiveRecord::Migration[7.0]
  def change
    add_reference :virtual_machines, :actor, null: true, foreign_key: true
    change_column :virtual_machines, :team_id, :integer, null: true
  end
end
