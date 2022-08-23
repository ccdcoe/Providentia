# frozen_string_literal: true

class AddNestedSetFieldsToOperatingSystem < ActiveRecord::Migration[6.0]
  def up
    change_table :operating_systems do |t|
      t.bigint :parent_id, null: true, index: true
      t.bigint :lft, null: true, index: true
      t.bigint :rgt, null: true, index: true
    end

    execute 'UPDATE operating_systems SET parent_id = ancestry::bigint'

    # OperatingSystem.reset_column_information
    # OperatingSystem.rebuild!

    change_column_null :operating_systems, :lft, false
    change_column_null :operating_systems, :rgt, false

    remove_column :operating_systems, :ancestry
  end

  def down
    add_column :operating_systems, :ancestry, :string
    add_index :operating_systems, :ancestry

    execute 'UPDATE operating_systems SET ancestry = parent_id::varchar'

    remove_column :operating_systems, :parent_id
    remove_column :operating_systems, :lft
    remove_column :operating_systems, :rgt
  end
end
