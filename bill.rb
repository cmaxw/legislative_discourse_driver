class Bill
  attr_reader :metadata, :session, :session_tag, :number, :token, :sponsor_name, :sponsor_tag, :link, :sections_affected

  def initialize(session:, number:, token: ENV["UTAH_LEGISLATURE_DEVELOPER_TOKEN"])
    @number = number
    @session = session
    @session_tag = session.sub("GS", "-general-session")
    @token = token
    get_metadata
  end

  def year
    session.to_i
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

  def get_metadata
    response = Faraday.get("https://glen.le.utah.gov/bills/#{session}/#{number}/#{token}")
    @metadata = JSON.parse(response.body)
    @short_number = metadata["billNumberShort"]
    @title = metadata["shortTitle"]
    @sponsor_name = metadata["primeSponsorName"]
    @floor_sponsor_name = metadata["floorSponsorName"]
    @sponsor_tag = "PS.#{metadata["primeSponsor"]}"
    @general_provisions = metadata["generalProvisions"]
    @moneys_appropriated = metadata["moneysAppropriated"]
    @sections_affected = metadata["billVersionList"].last["sectionAffectedList"].map { |section| section["secNo"] }.reject { |s| s == "effdate" }
    @subjects = metadata["billVersionList"].last["subjectList"].map { |section| section["description"] }
    @link = "https://le.utah.gov/~#{year}/bills/static/#{number}.html"
  end

  def discourse_title
    [@short_number, @title].join(" ")
  end

  def raw_post_content
    <<-POST
### Link to Bill: [#{@link}](#{@link})
### Bill Sponsor: #{@sponsor_name}
### Floor Sponsor: #{@floor_sponsor_name}
### General Provisions (as shown on the bill):

#{@general_provisions}

### Sections Affected: 
- #{@sections_affected.join("\n- ")}
      
### Subjects: 
- #{@subjects.join("\n- ")}
    POST
  end

  def tags
    [session_tag, sponsor_tag]
  end
end
