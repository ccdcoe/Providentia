# frozen_string_literal: true

class CreateAddresses < ActiveRecord::Migration[6.1]
  def change
    create_table :addresses do |t|
      t.references :network_interface, null: false, foreign_key: true
      t.integer :mode, null: false
      t.string :offset
      t.boolean :dns_enabled, default: false, null: false

      t.timestamps
    end
  end
end
