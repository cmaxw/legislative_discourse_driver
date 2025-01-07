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
end
