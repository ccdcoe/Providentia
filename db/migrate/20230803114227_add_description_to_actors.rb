# frozen_string_literal: true

class AddDescriptionToActors < ActiveRecord::Migration[7.0]
  def change
    add_column :actors, :description, :text
  end
end
