require "./lib/dbconfig"

class AddActiveToBillVersions < ActiveRecord::Migration[7.2]
  def change
    add_column :bill_versions, :active, :boolean, default: false
  end
end
