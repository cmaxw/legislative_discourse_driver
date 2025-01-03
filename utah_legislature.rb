require "bundler/setup"
require "dotenv"
Dotenv.load
require "faraday"

require "./bill"

class UtahLegislature
  attr_reader :session, :token

  def initialize(session: "2025GS", token: ENV["UTAH_LEGISLATURE_DEVELOPER_TOKEN"])
    @session = session
    @token = token
  end

  def get_bills
    response = Faraday.get("https://glen.le.utah.gov/bills/#{session}/billlist/#{token}")
    JSON.parse(response.body).map do |bill|
      Bill.new(session: session, number: bill["number"])
    end
  end
end
