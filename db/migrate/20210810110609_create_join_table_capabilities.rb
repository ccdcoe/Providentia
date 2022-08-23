# frozen_string_literal: true

class CreateJoinTableCapabilities < ActiveRecord::Migration[6.1]
  def change
    create_join_table :capabilities, :virtual_machines do |t|
      t.index [:virtual_machine_id, :capability_id], name: 'vm_capability_index'
    end
  end
end
