# frozen_string_literal: true

class AddNumberToActors < ActiveRecord::Migration[7.0]
  def change
    add_column :actors, :number, :integer, default: nil

    reversible do |direction|
      direction.up do
        # create a distributors view
        execute <<-SQL
          UPDATE actors
          set number = ((prefs->'numbered'->'count')::int + coalesce((prefs->'numbered'->>'dev_count'), '0')::int)
          where prefs @? '$.numbered';
        SQL
      end
    end
  end
end
