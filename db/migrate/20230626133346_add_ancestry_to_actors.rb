# frozen_string_literal: true

class AddAncestryToActors < ActiveRecord::Migration[7.0]
  def change
    add_column :actors, :ancestry, :string
    add_index :actors, :ancestry
  end
end
