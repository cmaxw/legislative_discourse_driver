require "bundler/setup"
require "dotenv"
Dotenv.load
require "discourse_api"
require "open_router"
require "awesome_print"
require "feedjira"

OpenRouter.configure do |config|
  config.access_token = ENV["OPENROUTER_API_KEY"]
  config.site_name = "UCRP Policy Portal"
  config.site_url = "https://ucrp.discourse.group"
end

require File.dirname(__FILE__) + "/utah_legislature"
require File.dirname(__FILE__) + "/discourse"
