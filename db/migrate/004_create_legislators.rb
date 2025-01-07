require "./lib/dbconfig"

class CreateLegislators < ActiveRecord::Migration[7.2]
  def change
    create_table :legislators do |table|
      table.string :tag
      table.integer :chamber
      table.string :full_name
      table.integer :party
      table.integer :district
      table.string :counties
      table.timestamps
    end

    add_index :legislators, :tag, unique: true
    add_column :bills, :prime_sponsor_id, :integer
    add_index :bills, :prime_sponsor_id
    add_column :bills, :floor_sponsor_id, :integer
    add_index :bills, :floor_sponsor_id
    add_column :bill_versions, :sponsor_id, :integer
    add_index :bill_versions, :sponsor_id
  end
end
