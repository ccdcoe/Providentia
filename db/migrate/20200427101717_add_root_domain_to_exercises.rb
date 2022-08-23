# frozen_string_literal: true

class AddRootDomainToExercises < ActiveRecord::Migration[6.0]
  def change
    add_column :exercises, :root_domain, :string
  end
end
