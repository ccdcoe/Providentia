class AddConnectionToAddresses < ActiveRecord::Migration[7.0]
  def change
    add_column :addresses, :connection, :boolean, default: false, null: false
  end
end
