# frozen_string_literal: true

class AlterSlugIndexOnNetworks < ActiveRecord::Migration[6.1]
  def change
    remove_index :networks, :slug, unique: true
  end
end
