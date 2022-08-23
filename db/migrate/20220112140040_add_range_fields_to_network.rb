# frozen_string_literal: true

class AddRangeFieldsToNetwork < ActiveRecord::Migration[6.1]
  def change
    add_column :networks, :range_start, :integer
    add_column :networks, :range_end, :integer
  end
end
