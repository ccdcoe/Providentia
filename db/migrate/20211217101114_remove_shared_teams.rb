# frozen_string_literal: true

class RemoveSharedTeams < ActiveRecord::Migration[6.1]
  def up
    remove_column :exercises, :shared_team_count
    remove_column :exercises, :shared_team_mapping

    execute "DELETE FROM teams where name = 'Shared'"
  end

  def down
  end
end
