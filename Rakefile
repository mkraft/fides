#!/usr/bin/env rake

require "bundler/gem_tasks"
require 'rake/testtask'
require 'pg'
require 'yaml'
require 'sqlite3'
require 'pry'
require_relative 'test/integration/db_test'

SQLITE3_FILE_PATH = "test/db/fides_test.sqlite3"

def postgres_db(opts)
  path = File.join(File.dirname(__FILE__), "test", "config", "database.yml")
  yaml = YAML.load_file(path)
  pg_connection_config = yaml["postgresql"]
  begin
    conn = PG.connect(dbname: 'postgres', 
                      password: pg_connection_config["password"], 
                      host: pg_connection_config["host"], 
                      user: pg_connection_config["username"])
    conn.exec("DROP DATABASE IF EXISTS #{pg_connection_config['database']};") {}
    conn.exec("CREATE DATABASE #{pg_connection_config['database']};") {} if opts[:create]
  rescue PGError => e
    puts e
  ensure
    conn.close unless conn.nil?
  end    
end

def create_sqlite3_db
  File.delete(SQLITE3_FILE_PATH) if File.exists?(SQLITE3_FILE_PATH)
  db = SQLite3::Database.new SQLITE3_FILE_PATH
end

def destroy_sqlite3_db
  File.delete(SQLITE3_FILE_PATH)
end

namespace :test do

  Rake::TestTask.new do |t|
    t.name = :unit
    t.libs << 'lib/fides'
    t.test_files = FileList['test/unit/*_test.rb']
    t.verbose = true
  end

  task :postgresql do
    postgres_db(:create => false)
    postgres_db(:create => true)
    Fides.run_common_tests("postgresql")
  end

  task :sqlite3 do
    # destroy_sqlite3_db
    create_sqlite3_db
    Fides.run_common_tests("sqlite3")
  end

end