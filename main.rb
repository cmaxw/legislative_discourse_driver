require "./lib/setup"

legislature = UtahLegislature.new
legislature.sync_legislators
legislature.sync_committees
legislature.sync_bills
legislature.sync_committee_bills
