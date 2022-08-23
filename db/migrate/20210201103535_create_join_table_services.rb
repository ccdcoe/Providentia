# frozen_string_literal: true

class CreateJoinTableServices < ActiveRecord::Migration[6.1]
  def change
    create_join_table :services, :virtual_machines do |t|
      t.index [:virtual_machine_id, :service_id], name: 'vm_service_index'
    end
  end
end
