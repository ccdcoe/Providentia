# frozen_string_literal: true

class CreateSpecialChecks < ActiveRecord::Migration[6.1]
  def change
    create_table :special_checks do |t|
      t.references :service, null: false, foreign_key: true
      t.references :network, null: false, foreign_key: true
      t.string :name, null: false

      t.timestamps
    end
  end
end
