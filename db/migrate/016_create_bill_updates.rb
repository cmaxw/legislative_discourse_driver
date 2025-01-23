require "./lib/dbconfig"

class CreateBillUpdates < ActiveRecord::Migration[7.2]
  def change
    create_table :bill_updates do |t|
      t.string :description
      t.string :owner
      t.date :action_date
      t.string :action_class
      t.string :vote_id
      t.string :voice_vote
      t.string :vote_house
      t.string :vote_string
      t.references :bill
    end
  end
end
