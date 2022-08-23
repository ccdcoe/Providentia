# frozen_string_literal: true

class CreateNetworks < ActiveRecord::Migration[6.0]
  def change
    create_table :networks do |t|
      t.references :exercise, null: false, foreign_key: true
      t.string :name, null: false
      t.string :abbreviation, null: false
      t.string :cloud_id
      t.string :ipv4
      t.string :ipv6
      t.text :description

      t.timestamps
    end
  end
end
