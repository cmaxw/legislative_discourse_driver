require "nokogiri"

class Bill
  attr_reader :metadata, :session, :session_tag, :number, :token, :sponsor_name, :sponsor_tag, :link, :sections_affected, :title

  def initialize(session:, number:, token: ENV["UTAH_LEGISLATURE_DEVELOPER_TOKEN"])
    @number = number
    @session = session
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
    bill_version_details_url = metadata["billVersionList"].last["billDocs"].last["url"]
    xml_details = Nokogiri::XML(Faraday.get("https://le.utah.gov/#{bill_version_details_url}").body)
    @metadata[:xml_details] = xml_details

    @short_number = metadata["billNumberShort"]
    @title = metadata["shortTitle"]
    @sponsor_name = metadata["primeSponsorName"]
    @floor_sponsor_name = metadata["floorSponsorName"]
    @prime_sponsor_tag = metadata["primeSponsor"]
    @floor_sponsor_tag = metadata["floorSponsor"]
    @sponsor_tags = [@prime_sponsor_tag, @floor_sponsor_tag].compact
    @general_provisions = metadata["generalProvisions"]
    @moneys_appropriated = metadata["moneysAppropriated"]
    @sections_affected = metadata["billVersionList"].last["sectionAffectedList"].map { |section| section["secNo"] }.reject { |s| s == "effdate" }
    @subjects = metadata["billVersionList"].last["subjectList"].map { |section| section["description"] }
    @link = "https://le.utah.gov/~#{year}/bills/static/#{number}.html"
    @committee_recommendations = metadata["recommendingCommitteeList"].map { |cr| cr["name"] }
  end

  def discourse_title
    [@short_number, @title].join(" ")
  end

  def raw_post_content
    <<-POST
### Link to Bill: [#{@link}](#{@link})
### Bill Sponsor: [#{@sponsor_name}](https://ucrp.discourse.group/tag/#{@prime_sponsor_tag})
### Floor Sponsor: #{"[#{@floor_sponsor_name}](https://ucrp.discourse.group/tag/#{@floor_sponsor_tag})" if @floor_sponsor_name && @floor_sponsor_name.length > 0}
### General Provisions (as shown on the bill):

#{@general_provisions}

### Sections Affected: 
- #{@sections_affected.join("\n- ")}

### Subjects: 
- #{@subjects.join("\n- ")}

### Recommending Committees:
- #{@committee_recommendations.join("\n- ")}

> PURPOSE OF THIS PAGE: Delegates work together to measure the proposed changes to this bill against our [Party Platform](https://ucrp.org/party-platform/) and related Republican principles. We will use the comments and answers you provide below to communicate action items to the relevant State Representatives and Senators at the appropriate times, based on the lifecycle of the bill.

> INSTRUCTIONS:
>1. Read the posted summary of proposed changes and follow the suggestions for further research.
>  a. Review the official bill page at the provided link above.
> 2. Select your final choice from the options below (we will use this to flag which bills need special attention). 
> 3. Reply to the comment thread below to explain your reasoning and collaborate with other delegates. 

**Based on the Party Platform:** 
[poll type=multiple results=always min=1 max=1 public=true chartType=bar]
* :red_square: This bill should red flagged (add comment below)
* :green_heart: This bill should be passed (add comment below)
[/poll]

    POST
  end

  def tags
    [session, @sponsor_tags].flatten.compact
  end
end
