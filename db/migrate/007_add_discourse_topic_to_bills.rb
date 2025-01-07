require "./lib/dbconfig"

class AddDiscourseTopicToBills < ActiveRecord::Migration[7.2]
  def change
    add_column :bills, :discourse_topic_id, :string
  end
end
