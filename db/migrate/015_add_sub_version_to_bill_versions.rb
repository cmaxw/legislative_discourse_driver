require "./lib/dbconfig"

class AddSubVersionToBillVersions < ActiveRecord::Migration[7.2]
  def change
    add_column :bill_versions, :sub_version, :integer
  end
end
