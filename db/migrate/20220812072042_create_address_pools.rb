# frozen_string_literal: true

class CreateAddressPools < ActiveRecord::Migration[7.0]
  def change
    create_table :address_pools do |t|
      t.references :network, null: false, foreign_key: true
      t.string :name, null: false
      t.string :slug, null: false
      t.integer :ip_family, null: false, default: 1
      t.integer :scope, null: false, default: 1
      t.string :network_address
      t.bigint :gateway, default: 0
      t.integer :range_start
      t.integer :range_end

      t.timestamps
    end
  end
end
