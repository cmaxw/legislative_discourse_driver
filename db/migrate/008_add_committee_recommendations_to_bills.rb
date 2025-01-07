require "./lib/dbconfig"

class AddCommitteeRecommendationsToBills < ActiveRecord::Migration[7.2]
  def change
    add_column :bills, :committee_recommendations, :text
  end
end
