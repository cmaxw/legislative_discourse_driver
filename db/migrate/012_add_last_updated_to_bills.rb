require "./lib/dbconfig"

class AddLastUpdatedToBills < ActiveRecord::Migration[7.2]
  def change
    add_column :bills, :last_updated, :datetime
  end
end
