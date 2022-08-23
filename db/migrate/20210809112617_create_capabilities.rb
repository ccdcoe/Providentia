# frozen_string_literal: true

class CreateCapabilities < ActiveRecord::Migration[6.1]
  def change
    create_table :capabilities do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.references :exercise, null: false, foreign_key: true

      t.timestamps
    end
  end
end
