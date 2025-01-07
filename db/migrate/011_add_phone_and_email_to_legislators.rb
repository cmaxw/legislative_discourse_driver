require "./lib/dbconfig"

class AddPhoneAndEmailToLegislators < ActiveRecord::Migration[7.2]
  def change
    add_column :legislators, :email, :string
    add_column :legislators, :phone, :string
  end
end
