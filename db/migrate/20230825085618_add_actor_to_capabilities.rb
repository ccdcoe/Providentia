# frozen_string_literal: true

class AddActorToCapabilities < ActiveRecord::Migration[7.0]
  def change
    add_reference :capabilities, :actor, null: true, foreign_key: true
  end
end
