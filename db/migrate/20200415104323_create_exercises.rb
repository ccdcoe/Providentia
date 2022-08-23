# frozen_string_literal: true

class CreateExercises < ActiveRecord::Migration[6.0]
  def change
    create_table :exercises do |t|
      t.string :name
      t.string :abbreviation

      t.timestamps
    end

    add_index :exercises, :abbreviation, unique: true
  end
end
