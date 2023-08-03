# frozen_string_literal: true

class ChangeNumberedByToPolymorphic < ActiveRecord::Migration[7.0]
  def change
    add_column :virtual_machines, :numbered_by_type, :string
    rename_column :virtual_machines, :numbered_by, :numbered_by_id

    reversible do |direction|
      direction.up do
        execute <<-SQL
          UPDATE virtual_machines
          set numbered_by_type = 'Actor'
          where numbered_by_id is not null;
        SQL
      end
    end
  end
end
