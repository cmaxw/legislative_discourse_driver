require "./lib/dbconfig"

class ConnectCommitteesToLegislators < ActiveRecord::Migration[7.2]
  def change
    create_join_table :committees, :legislators
  end
end
