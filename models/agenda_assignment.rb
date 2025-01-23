class AgendaAssignment < ActiveRecord::Base
  belongs_to :bill
  belongs_to :committee

  delegate :session, to: :bill
end