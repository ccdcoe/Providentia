# frozen_string_literal: true

class CreateNetworkInterfaces < ActiveRecord::Migration[6.0]
  def change
    create_table :network_interfaces do |t|
      t.references :virtual_machine, null: false, foreign_key: true
      t.references :network, null: false, foreign_key: true

      t.timestamps
    end
  end
end
