require "./lib/dbconfig"

class AddStatusToBillVersions < ActiveRecord::Migration[7.2]
  def change
    add_column :bill_versions, :status, :boolean, default: false
  end
end
