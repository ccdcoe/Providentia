# frozen_string_literal: true

class CreateServices < ActiveRecord::Migration[6.1]
  def change
    create_table :services do |t|
      t.references :exercise, null: false, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
