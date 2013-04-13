#!/usr/bin/env rake

require "bundler/gem_tasks"
require 'rake/testtask'
require 'pg'
require 'yaml'
require 'sqlite3'

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
  db = SQLite3::Database.new "test/db/fides_test.sqlite3"
end

def destroy_sqlite3_db
  File.delete("test/db/fides_test.sqlite3")
end

task :create_databases do
  postgres_db(:create => true)
  create_sqlite3_db
end

task :destroy_databases do
  postgres_db(:create => false)
  destroy_sqlite3_db
end

Rake::TestTask.new do |t|
  t.name = :run_tests
  t.libs << 'lib/fides'
  t.test_files = FileList['test/unit/*_test.rb', 'test/integration/*_test.rb']
  t.verbose = true
end

task :test =>  [:create_databases, :run_tests, :destroy_databases]