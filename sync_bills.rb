require "bundler/setup"
require "dotenv"
Dotenv.load
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
  end
end
