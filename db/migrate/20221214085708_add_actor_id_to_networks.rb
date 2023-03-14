# frozen_string_literal: true

class AddActorIdToNetworks < ActiveRecord::Migration[7.0]
  def change
    add_reference :networks, :actor, null: true, foreign_key: true
    change_column :networks, :team_id, :integer, null: true
  end
end
