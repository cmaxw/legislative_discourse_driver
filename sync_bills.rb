require "bundler/setup"
require "dotenv"
Dotenv.load
require "discourse_api"
require "./utah_legislature"

class SyncBills
  def execute
    bills = UtahLegislature.get_bills
    bills.each do |bill|
      sync_topic(bill)
    end
  end

  private

  def sync_topic(bill)
    client = DiscourseApi::Client.new(ENV["DISCOURSE_URL"])
    client.api_key = ENV["DISCOURSE_API_KEY"]
    client.api_username = ENV["DISCOURSE_USERNAME"]

    client.create_topic(bill.for_discourse)
  end
end
