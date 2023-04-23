# frozen_string_literal: true

class AddSlugToServices < ActiveRecord::Migration[7.0]
  def change
    add_column :services, :slug, :string
  end
end
