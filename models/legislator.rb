# == Schema Information
#
# Table name: legislators
#
#  id                                 :integer          not null, primary key
#  tag                                :string
#  chamber                            :integer
#  full_name                          :string
#  party                              :integer
#  district                           :integer
#  counties                           :string
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  email                              :string
#  phone                              :string
#  discourse_committee_topic_id       :integer
#  discourse_sponsored_bills_topic_id :integer
#
class Legislator < ActiveRecord::Base
  has_many :bill_versions, as: :sponsor
  has_many :sponsored_bills, as: :prime_sponsor
  has_many :floor_bills, as: :floor_sponsor
  has_and_belongs_to_many :committees

  enum :chamber, [:house, :senate]
  enum :party, [:republican, :democrat, :other]

  def self.import(attrs_hash)
    legislator = Legislator.find_or_create_by(tag: attrs_hash["id"])
    legislator.update({
      chamber: import_chamber(attrs_hash["house"]),
      full_name: attrs_hash["fullName"],
      party: import_party(attrs_hash["party"]),
      district: attrs_hash["district"].to_i,
      counties: attrs_hash["counties"],
      email: attrs_hash["email"],
      phone: attrs_hash["workPhone"],
    })
  end

  def utah_county?
    counties.downcase.split(",").map(&:strip).include?("utah")
  end

  private

  def self.import_chamber(house)
    house == "H" ? :house : :senate
  end

  def self.import_party(party)
    case party
    when "R"
      :republican
    when "D"
      :democrat
    else
      :other
    end
  end
end
