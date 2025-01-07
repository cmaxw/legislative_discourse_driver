require "./lib/dbconfig"

class CreateCommittees < ActiveRecord::Migration[7.2]
  def change
    create_table :committees do |table|
      table.string :tag
      table.string :full_name
      table.integer :link
      table.timestamps
    end
  end
end
