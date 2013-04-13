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

def setup_postgres
  path = File.join(File.dirname(__FILE__), "config", "database.yml")      
  yaml = YAML.load_file(path)
  pg_connection_config = yaml["postgresql"]
  ActiveRecord::Base.establish_connection(pg_connection_config)

  Rails.stub :env, "test" do
    ActiveRecord::Base.stub :configurations, { "test" => { "adapter" => "postgresql" } } do
      CreateTestTables.new.change
    end
  end
end

def setup_sqlite3
  path = File.join(File.dirname(__FILE__), "config", "database.yml")      
  yaml = YAML.load_file(path)
  connection_config = yaml["sqlite3"]
  ActiveRecord::Base.establish_connection(connection_config)

  Rails.stub :env, "test" do
    ActiveRecord::Base.stub :configurations, { "test" => { "adapter" => "sqlite3" } } do
      CreateTestTables.new.change
    end
  end
end

def teardown_postgres
  path = File.join(File.dirname(__FILE__), "config", "database.yml")      
  yaml = YAML.load_file(path)
  pg_connection_config = yaml["postgresql"]
  ActiveRecord::Base.establish_connection(pg_connection_config)

  begin
    conn = PG.connect(dbname: 'postgres', 
                      password: pg_connection_config["password"], 
                      host: pg_connection_config["host"], 
                      user: pg_connection_config["username"])
    conn.exec("DROP DATABASE IF EXISTS #{pg_connection_config['database']};") {}
  rescue PGError => e
    puts e
  ensure
    conn.close unless conn.nil?
  end   
end

def teardown_sqlite3
end

MiniTest::Unit.after_tests do
  # teardown_postgres
  teardown_sqlite3
end