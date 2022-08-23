# frozen_string_literal: true

class CreateServiceChecks < ActiveRecord::Migration[6.1]
  def change
    create_table :service_checks do |t|
      t.references :service, null: false, foreign_key: true
      t.references :network, null: false, foreign_key: true
      t.integer :protocol, default: 0, null: false
      t.integer :ip_family, default: 0, null: false
      t.integer :destination_port

      t.timestamps
    end
  end
end
