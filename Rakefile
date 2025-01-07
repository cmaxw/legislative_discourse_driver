require "./lib/setup"

namespace "db" do
  task :migrate do
    ActiveRecord::MigrationContext.new("db/migrate/").migrate
  end
end
