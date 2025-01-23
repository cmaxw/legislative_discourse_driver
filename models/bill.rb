class Bill < ActiveRecord::Base
  belongs_to :session
  belongs_to :prime_sponsor, class_name: "Legislator"
  belongs_to :floor_sponsor, class_name: "Legislator"
  has_many :bill_versions, dependent: :destroy
  has_many :bill_updates, dependent: :destroy
  has_many :agenda_assignments, dependent: :destroy
  has_many :upcoming_agenda_assignments, -> { where(upcoming: true)}, class_name: "AgendaAssignment"

  def active_version
    bill_versions.active.first
  end

  def self.import(session:, number:, updatetime:)
    token = ENV["UTAH_LEGISLATURE_DEVELOPER_TOKEN"]
    metadata = JSON.parse(Faraday.get("https://glen.le.utah.gov/bills/#{session}/#{number}/#{token}").body)

    current_session = Session.find_or_create_by(tag: metadata["sessionID"])
    current_bill = current_session.bills.find_or_create_by(tracking_id: metadata["trackingID"])

    update_time = DateTime.parse(updatetime)
    if current_bill.last_updated.nil? || current_bill.last_updated < update_time
      new_versions = []
      year = current_session.year

      current_bill.number = metadata["billNumber"]
      current_bill.short_number = metadata["billNumberShort"]
      current_bill.title = metadata["shortTitle"]
      current_bill.general_provisions = metadata["generalProvisions"]
      current_bill.moneys_appropriated = metadata["moniesAppropriated"]
      current_bill.link = "https://le.utah.gov/~#{year}/bills/static/#{number}.html"
      current_bill.committee_recommendations = metadata["recommendingCommitteeList"].map { |cr| "- #{cr["name"]}\n" }.join
      current_bill.prime_sponsor = Legislator.find_by(tag: metadata["primeSponsor"])
      current_bill.floor_sponsor = Legislator.find_by(tag: metadata["floorSponsor"])

      metadata["billVersionList"].each do |bill_version|
        current_version = current_bill.bill_versions.find_or_create_by(tracking_id: bill_version["subTrackID"])
        current_version.subjects = bill_version["subjectList"].map { |section| "- #{section["description"]}\n" }.join
        current_version.sections_affected = bill_version["sectionAffectedList"].map { |section| section["secNo"] }.reject { |s| s == "effdate" }.map { |section| "- #{section}\n" }.join
        current_version.version_number = bill_version["minorVersion"]
        current_version.active = bill_version["activeVersion"]
        current_version.sponsor = Legislator.find_by(tag: bill_version["versionSponsor"])
        current_version.status = bill_version["billDocs"].last["fileType"]
        current_version.sub_version = bill_version["subVersion"]
        new_versions << current_version if current_version.new_record?
        current_version.save!
      end
      if current_bill.discourse_topic_id.nil? || current_bill.new_record?
        current_bill.create_discourse_topic
      end
      current_bill.post_bill_updates(metadata["actionHistoryList"])
      current_bill.post_agenda_assignments(metadata["agendaList"])
      current_bill.last_updated = update_time
      current_bill.save!
    end
  end

  def create_discourse_topic
    begin
      discourse = Discourse.new
      discourse_topic = discourse.create_topic(for_discourse)
    rescue => e
      ap for_discourse
      raise e      
    end
    self.discourse_topic_id = discourse_topic["topic_id"]
  end

  def post_bill_updates(action_history)
    discourse = Discourse.new
    action_history.select do |bill_update|
      last_updated.nil? || Date.strptime(bill_update["actionDate"], "%M/%d/%Y") >= last_updated
    end.each_with_index do |bill_update, index|
      unless bill_updates.find_by(description: bill_update["description"],
                                  owner: bill_update["owner"],
                                  action_date: Date.strptime(bill_update["actionDate"], "%M/%d/%Y"),
                                  action_class: bill_update["actionClass"],
                                  vote_id: bill_update["voteID"],
                                  voice_vote: bill_update["voiceVote"],
                                  vote_house: bill_update["voteHouse"],
                                  vote_string: bill_update["voiceStr"])
        post_body = bill_update.select {|k, v| v != "" && !v.nil? && !["actionDate", "actionClass"].include?(k)}
                                .map {|k,v| "#{k.underscore.humanize.capitalize}: #{v}"}
                                .join("\n\n")
                                .gsub("House/", "House")
                                .gsub("Senate/", "Senate")
        raw_update_post = <<-POST
### Updated on #{bill_update["actionDate"]}

#{post_body}
        POST
        discourse.create_post(topic_id: discourse_topic_id, raw: raw_update_post)
        bill_updates.create!(description: bill_update["description"],
                            owner: bill_update["owner"],
                            action_date: Date.strptime(bill_update["actionDate"], "%M/%d/%Y"),
                            action_class: bill_update["actionClass"],
                            vote_id: bill_update["voteID"],
                            voice_vote: bill_update["voiceVote"],
                            vote_house: bill_update["voteHouse"],
                            vote_string: bill_update["voteStr"])
        sleep 5 if index%8 == 0
      end
    end
  end

  def post_agenda_assignments(agenda_assignments)
    discourse = Discourse.new
    agenda_assignments.select do |item|
      item["upcoming"]
    end.each do |item|
      committee = Committee.find_by(tag: item["committeeID"])
      unless agenda_assignments.find_by(meeting_id: item["mtgId"]) && item["upcoming"]
        meeting_at = DateTime.strptime(item["mtgDate"], "%M/%d/%Y")
        meeting_at_humanized = meeting_at.strftime("%m/%d/%Y %i:%M %P")                                
        raw_update_post = <<-POST
### Added to #{item["committeeName"]} agenda for #{meeting_at_humanized}

Agenda Item: ##{item["agendaItem"]}

Meeting Place: #{item["mtgPlace"]}

Meeting Agenda: https://le.utah.gov/#{item["agendaURL"]}
        POST
        discourse.create_post(topic: discourse_topic_id, raw: post_body)
        agenda_assignments.create!(meeting_id: item["mtgID"],
                                  committee: committee,
                                  meeting_at: DateTime.parse(item["mtDate"]),
                                  meeting_place: item["mtgPlace"],
                                  upcoming: item["upcoming"],
                                  minutes_url: item["minutesURL"],
                                  agenda_url: item["agendaURL"])
        committee.legislators.each do |legislator|

        end
      else
        item = agenda_assignments.find_or_create_by(meeting_id: item["mtgId"])
        item.update!(meeting_id: item["mtgID"],
                    committee: committee,
                    meeting_at: DateTime.parse(item["mtDate"]),
                    meeting_place: item["mtgPlace"],
                    upcoming: item["upcoming"],
                    minutes_url: item["minutesURL"],
                    agenda_url: item["agendaURL"])
      end
    end
  end

  def for_discourse
    {
      title: discourse_title,
      raw: raw_post_content,
      category: ENV["DISCOURSE_DEFAULT_CATEGORY"],
      tags: tags,
    }
  end

  private

  def discourse_title
    [short_number, title].join(" ")
  end

  def raw_post_content
    <<-POST
### Link to Bill: [#{link}](#{link})
### Bill Sponsor: [#{prime_sponsor.full_name}](https://ucrp.discourse.group/tags/c/all-bills-lcc/#{prime_sponsor.tag}?board=default)
Email: [#{prime_sponsor.email}](mailto:#{prime_sponsor.email})
Phone: [#{prime_sponsor.phone}](tel:#{prime_sponsor.email})

### Floor Sponsor: #{"[#{floor_sponsor.full_name}](https://ucrp.discourse.group/tag/#{floor_sponsor.tag})" if floor_sponsor}
#{"Email: [#{floor_sponsor.email}](mailto:#{floor_sponsor.email})" if floor_sponsor}
#{"Phone: [#{floor_sponsor.phone}](tel:#{floor_sponsor.email})" if floor_sponsor}

### General Provisions (as shown on the bill):

#{general_provisions}

### Sections Affected: 
#{active_version.sections_affected}

### Subjects: 
#{active_version.subjects}

### Recommending Committees:
#{committee_recommendations}

### Monies Appropriated: #{moneys_appropriated}

> PURPOSE OF THIS PAGE: Delegates work together to measure the proposed changes to this bill against our [Party Platform](https://ucrp.org/party-platform/) and related Republican principles. We will use the comments and answers you provide below to communicate action items to the relevant State Representatives and Senators at the appropriate times, based on the lifecycle of the bill.

> INSTRUCTIONS:
>1. Read the posted summary of proposed changes and follow the suggestions for further research.
>  a. Review the official bill page at the provided link above.
> 2. Select your final choice from the options below (we will use this to flag which bills need special attention). 
> 3. Reply to the comment thread below to explain your reasoning and collaborate with other delegates. 

**Based on the Party Platform:** 
[poll type=multiple results=always min=1 max=1 public=true chartType=bar]
* :red_square: This bill is a HARD NO and should be red flagged (add comment below)
* :green_square: This bill is a FIRM YES and should be passed (add comment below)
[/poll]

    POST
  end

  def tags
    [session.tag, sponsor_tags, active_version.status, committee_tags].flatten.compact
  end

  def sponsor_tags
    [prime_sponsor.tag, floor_sponsor&.tag].compact
  end

  def committee_tags
    upcoming_agenda_assignments.map(&:committee).map(&:tag)
  end
end
