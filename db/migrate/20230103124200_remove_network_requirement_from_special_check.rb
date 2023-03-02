# frozen_string_literal: true

class RemoveNetworkRequirementFromSpecialCheck < ActiveRecord::Migration[7.0]
  def change
    change_column :special_checks, :network_id, :bigint, null: true
  end
end
