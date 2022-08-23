# frozen_string_literal: true

class AddSlugToOperatingSystems < ActiveRecord::Migration[6.1]
  def change
    add_column :operating_systems, :slug, :string
    add_index :operating_systems, :slug, unique: true
  end
end
