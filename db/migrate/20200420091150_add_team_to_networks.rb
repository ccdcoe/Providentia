# frozen_string_literal: true

class AddTeamToNetworks < ActiveRecord::Migration[6.0]
  def change
    add_reference :networks, :team, null: false, foreign_key: true
  end
end
