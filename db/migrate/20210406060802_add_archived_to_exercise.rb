# frozen_string_literal: true

class AddArchivedToExercise < ActiveRecord::Migration[6.1]
  def change
    add_column :exercises, :archived, :boolean, null: false, default: false
  end
end
