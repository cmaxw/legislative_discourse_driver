# == Schema Information
#
# Table name: bill_versions
#
#  id                :integer          not null, primary key
#  version_number    :string
#  bill_id           :integer
#  tracking_id       :string
#  subjects          :text
#  sections_affected :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  sponsor_id        :integer
#  active            :boolean          default(FALSE)
#  status            :string
#  sub_version       :integer
#
class BillVersion < ActiveRecord::Base
  belongs_to :bill
  belongs_to :sponsor, class_name: "Legislator"

  scope :active, -> { where(active: true) }
end
