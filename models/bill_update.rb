# == Schema Information
#
# Table name: bill_updates
#
#  id           :integer          not null, primary key
#  description  :string
#  owner        :string
#  action_date  :date
#  action_class :string
#  vote_id      :string
#  voice_vote   :string
#  vote_house   :string
#  vote_string  :string
#  bill_id      :integer
#
class BillUpdate < ActiveRecord::Base
  belongs_to :bill
end
