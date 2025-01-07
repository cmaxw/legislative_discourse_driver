require "./lib/dbconfig"

class CreateBills < ActiveRecord::Migration[7.2]
  def change
    create_table :bills do |table|
      table.string :title
      table.references :session
      table.string :tracking_id
      table.integer :short_number
      table.text :general_provisions
      table.string :moneys_appropriated
      table.string :link
      table.timestamps
    end

    add_index :bills, [:session, :tracking_id], unique: true
  end
end
