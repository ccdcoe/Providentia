# frozen_string_literal: true

class AddFieldsToNetwork < ActiveRecord::Migration[6.0]
  def change
    add_column :networks, :gateway4, :integer, default: 1
    add_column :networks, :gateway6, :bigint, default: 1
    add_column :networks, :trunk, :boolean, default: false, null: false
  end
end
