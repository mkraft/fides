require 'minitest/autorun'
require 'minitest/pride'
require File.expand_path('../../lib/fides.rb', __FILE__)
require 'pry'
require 'pg'
require 'sqlite3'
require_relative 'integration/migrations/create_test_tables'
require_relative 'integration/models/baby'
require_relative 'integration/models/teenager'
require_relative 'integration/models/senior'
require_relative 'integration/models/clothing_article'

def migrate_database(adapter_name)
  path = File.join(File.dirname(__FILE__), "config", "database.yml")      
  yaml = YAML.load_file(path)
  connection_config = yaml[adapter_name]
  ActiveRecord::Base.establish_connection(connection_config)

  Rails.stub :env, "test" do
    ActiveRecord::Base.stub :configurations, { "test" => { "adapter" => adapter_name } } do
      CreateTestTables.new.change
    end
  end
end