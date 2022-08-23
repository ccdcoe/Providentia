# frozen_string_literal: true

class AddDefaultValueToSharedTeamMappings < ActiveRecord::Migration[6.0]
  def up
    change_column :exercises, :shared_team_mapping, :jsonb, default: {}
  end

  def down
  end
end
