# == Schema Information
#
# Table name: agenda_assignments
#
#  id            :integer          not null, primary key
#  meeting_id    :string
#  committee_id  :integer
#  bill_id       :integer
#  meeting_at    :datetime
#  meeting_place :string
#  agenda_item   :integer
#  upcoming      :boolean
#  minutes_url   :string
#  agenda_url    :string
#
class AgendaAssignment < ActiveRecord::Base
  belongs_to :bill
  belongs_to :committee

  delegate :session, to: :bill
end
