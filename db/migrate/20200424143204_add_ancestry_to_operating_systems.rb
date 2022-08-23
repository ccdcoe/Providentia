# frozen_string_literal: true

class AddAncestryToOperatingSystems < ActiveRecord::Migration[6.0]
  def change
    add_column :operating_systems, :ancestry, :string
    add_index :operating_systems, :ancestry
  end
end
