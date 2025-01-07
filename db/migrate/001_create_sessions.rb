require "./lib/dbconfig"

class CreateSessions < ActiveRecord::Migration[7.2]
  def change
    create_table :sessions do |table|
      table.string :name
      table.string :tag
      table.timestamps
    end
  end
end
