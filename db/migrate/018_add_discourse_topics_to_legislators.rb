require "./lib/dbconfig"

class AddDiscourseTopicsToLegislators < ActiveRecord::Migration[7.2]
  def change
    add_column :legislators, :discourse_committee_topic_id, :integer
    add_column :legislators, :discourse_sponsored_bills_topic_id, :integer
  end
end
