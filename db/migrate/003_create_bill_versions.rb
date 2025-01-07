require "./lib/dbconfig"

class CreateBillVersions < ActiveRecord::Migration[7.2]
  def change
    create_table :bill_versions do |table|
      table.string :version_number
      table.references :bill
      table.string :tracking_id
      table.text :subjects
      table.text :sections_affected
      table.timestamps
    end
  end
end
