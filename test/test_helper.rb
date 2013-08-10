require 'minitest/autorun'
require 'minitest/pride'
require File.expand_path('../../lib/fides.rb', __FILE__)
require 'pg'
require_relative 'integration/migrations/create_test_tables'
require_relative 'integration/migrations/add_triggers'
require_relative 'integration/models/baby'
require_relative 'integration/models/teenager'
require_relative 'integration/models/senior'
require_relative 'integration/models/clothing_article'

def execute_migration(adapter_name)
  path = File.join(File.dirname(__FILE__), "config", "database.yml")      
  yaml = YAML.load_file(path)
  yaml["sqlite3"] = { adapter: "sqlite3", database: File.join(File.dirname(__FILE__), "db", "fides_test.sqlite3") }
  connection_config = yaml[adapter_name]

  ActiveRecord::Base.establish_connection(connection_config)
  Rails.stub :env, "test" do
    ActiveRecord::Base.stub :configurations, { "test" => { "adapter" => adapter_name } } do
      yield
    end
  end
end