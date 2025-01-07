require "./lib/dbconfig"

class AddNumberToBills < ActiveRecord::Migration[7.2]
  def change
    add_column :bills, :number, :string
  end
end
