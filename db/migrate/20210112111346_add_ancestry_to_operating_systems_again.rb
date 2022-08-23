# frozen_string_literal: true

class AddAncestryToOperatingSystemsAgain < ActiveRecord::Migration[6.0]
  def up
    add_column :operating_systems, :ancestry, :string
    add_index :operating_systems, :ancestry

    OperatingSystem.build_ancestry_from_parent_ids!

    remove_column :operating_systems, :parent_id
    remove_column :operating_systems, :lft
    remove_column :operating_systems, :rgt
  end

  def down
  end
end
