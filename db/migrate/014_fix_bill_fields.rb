require "./lib/dbconfig"

class FixBillFields < ActiveRecord::Migration[7.2]
  def up
    change_column :bill_versions, :status, :string
    change_column :bills, :short_number, :string
  end

  def down
    change_column :bill_versions, :status, :boolean
    change_column :bills, :short_number, :integer
  end
end
