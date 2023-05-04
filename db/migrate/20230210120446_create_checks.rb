# frozen_string_literal: true

class CreateChecks < ActiveRecord::Migration[7.0]
  def change
    create_table :checks do |t|
      t.references :service, null: false, foreign_key: true
      t.references :source, polymorphic: true, index: true, null: false
      t.references :destination, polymorphic: true, index: true, null: false
      t.integer :check_mode, null: false, default: 1
      t.string :special_label
      t.integer :protocol
      t.integer :ip_family
      t.string :port
      t.jsonb :config_map, default: nil
      t.boolean :scored, null: false, default: true

      t.timestamps
    end
  end
end
