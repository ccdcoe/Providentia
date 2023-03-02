class AddScorabilityToChecks < ActiveRecord::Migration[7.0]
  def change
    add_column :special_checks, :scored, :boolean, default: true, null: false
    add_column :service_checks, :scored, :boolean, default: true, null: false
  end
end
