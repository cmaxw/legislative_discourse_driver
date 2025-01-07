require "active_record"

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: "db/production.db",
)

Dir[File.join(__dir__, "..", "models", "*.rb")].each { |file| require file }
