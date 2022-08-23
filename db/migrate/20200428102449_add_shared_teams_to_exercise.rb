# frozen_string_literal: true

class AddSharedTeamsToExercise < ActiveRecord::Migration[6.0]
  def change
    add_column :exercises, :shared_team_count, :integer
    add_column :exercises, :shared_team_mapping, :jsonb
  end
end
