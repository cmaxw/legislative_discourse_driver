require File.dirname(__FILE__) + "/dbconfig"

class UtahLegislature
  def token
    @token ||= ENV["UTAH_LEGISLATURE_DEVELOPER_TOKEN"]
  end

  def session
    @session ||= ENV["SESSION"]
  end

  def sync_legislators
    response = Faraday.get("https://glen.le.utah.gov/legislators/#{token}")
    JSON.parse(response.body)["legislators"].map do |legislator|
      Legislator.import(legislator)
    end
  end

  def sync_committees
    response = Faraday.get("https://glen.le.utah.gov/committees/#{token}")
    JSON.parse(response.body)["committees"].map do |committee|
      Committee.import(committee)
    end
  end

  def sync_bills
    response = Faraday.get("https://glen.le.utah.gov/bills/#{session}/billlist/#{token}")
    JSON.parse(response.body).map do |bill|
      Bill.import(session: session, number: bill["number"], updatetime: bill["updatetime"])
    end
  end

  def sync_committee_bills
    discourse = Discourse.new
    Committee.all.each do |committee|
      committee = Committee.find_by(tag: "HSTBUS")
      feed = Feedjira.parse(Faraday.get("https://le.utah.gov/asp/billtrack/comrssfeed.asp?com=HSTBUS").body)
      feed.entries.each do |entry|
        meetings = entry.summary.strip.split("<B>").each do |meeting|
          unless meeting == ""
            meeting_at = Time.strptime(" #{meeting.match(/\d{1,2}\/\d{1,2}\/\d{4} \d{1,2}:\d{2}:\d{2} [AP]M/).to_s}".gsub(/\/(\d)\//, '/0\1/'), "%e/%d/%Y %l:%M:%S %p")
            meeting_place = meeting.match(/[AP]M - (.*)<\/B>/)[1]
            bills = meeting.scan(/HB\d{4}|H[CJ]?R\d{4}|S[CJ]?R\d{4}|SB\d{4}/).uniq
            bills.each do |b|
              bill = Bill.find_by(number: b)
              if bill
                committee_assignment = bill.agenda_assignments.find_by(committee: committee, meeting_at: meeting_at, meeting_place: meeting_place)
                if committee_assignment.nil? && meeting_at >= Time.now
                  bill.agenda_assignments.create!(committee: committee, meeting_at: meeting_at, meeting_place: meeting_place)
                  post_body = "The #{committee.full_name} will be discussing #{bill.title} on #{meeting_at.in_time_zone("MST").strftime("%A, %B %e, %Y")} at #{meeting_place}."
                  discourse.create_post(topic_id: bill.discourse_topic_id, raw: post_body)
                  committee.legislators.each do |legislator|
                    if legislator.utah_county? && legislator.discourse_committee_topic_id
                      post_body = "#{legislator.full_name} is a member of #{committee.full_name}.\n\nThe #{committee.full_name} will be discussing #{bill.title} on #{meeting_at.in_time_zone("MST").strftime("%A, %B %e, %Y")} at #{meeting_place}.\n\n#{discourse.get_topic_link(bill.discourse_topic_id)}"
                      discourse.create_post(topic_id: legislator.discourse_committee_topic_id, raw: post_body)
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
