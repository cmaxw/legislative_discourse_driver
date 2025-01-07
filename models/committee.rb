class Committee < ActiveRecord::Base
  has_and_belongs_to_many :legislators

  def self.import(attrs_hash)
    committee = find_or_create_by(tag: attrs_hash["id"])
    committee.update({
      full_name: attrs_hash["description"],
      link: attrs_hash["hash"],
    })

    legislator_ids = attrs_hash["members"].map { |member| member["id"] }.map { |id| Legislator.find_by(tag: id).id }
    committee.legislator_ids = legislator_ids
  end
end
