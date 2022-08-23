# frozen_string_literal: true

class AddSlugToNetworks < ActiveRecord::Migration[6.1]
  def change
    add_column :networks, :slug, :string
    add_index :networks, :slug, unique: true
  end
end
