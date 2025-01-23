require "./lib/dbconfig"

class CreateAgendaAssignments < ActiveRecord::Migration[7.2]
  def change
    create_table :agenda_assignments do |t|
      t.string :meeting_id
      t.references :committee
      t.references :bill
      t.datetime :meeting_at
      t.string :meeting_place
      t.integer :agenda_item
      t.boolean :upcoming
      t.string :minutes_url
      t.string :agenda_url
    end
  end
end
