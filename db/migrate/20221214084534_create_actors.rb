# frozen_string_literal: true

class CreateActors < ActiveRecord::Migration[7.0]
  def change
    create_table :actors do |t|
      t.references :exercise, null: false, foreign_key: true
      t.string :abbreviation, null: false
      t.string :name, null: false
      t.jsonb :prefs, default: {}

      t.timestamps
    end
  end
end
