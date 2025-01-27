# == Schema Information
#
# Table name: committees
#
#  id         :integer          not null, primary key
#  tag        :string
#  full_name  :string
#  link       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Committee < ActiveRecord::Base
  has_and_belongs_to_many :legislators

  def self.import(attrs_hash)
    committee = find_or_create_by(tag: attrs_hash["id"])
    committee.update({
      full_name: attrs_hash["description"],
      link: attrs_hash["hash"],
    })

    legislator_ids = attrs_hash["members"].map { |member| member["id"] }.map { |id| Legislator.find_by(tag: id)&.id }.compact
    committee.legislator_ids = legislator_ids
  end
end
