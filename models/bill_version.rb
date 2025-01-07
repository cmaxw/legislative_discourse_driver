class BillVersion < ActiveRecord::Base
  belongs_to :bill
  belongs_to :sponsor, class_name: "Legislator"

  scope :active, -> { where(active: true) }
end
