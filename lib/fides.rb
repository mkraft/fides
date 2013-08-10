require 'rails'
require 'active_record'
require 'active_support/concern'
require 'active_support/inflector'
require 'fides/version'
require 'fides/sql_writer'
require 'fides/postgresql_writer'
require 'fides/sqlite3_writer'
require 'fides/database_adapter_error'

module Fides
  SUPPORTED_ADAPTERS = ["postgresql", "sqlite3"]

  extend ActiveSupport::Concern

  def add_polymorphic_triggers(opts)
    associated_models = opts.fetch(:associated_models)
    polymorphic_model = opts.fetch(:polymorphic_model)
    
    interface = (opts.has_key?(:interface_name) ? opts[:interface_name] : 
      interface_name(polymorphic_model))

    statements = sql_generator_class.executable_add_statements(
      interface, associated_models, polymorphic_model)
    
    statements.each { |statement| execute statement }
  end

  def remove_polymorphic_triggers(opts)
    polymorphic_model = opts.fetch(:polymorphic_model)
    
    interface = (opts.has_key?(:interface_name) ? opts[:interface_name] : 
      interface_name(polymorphic_model))

    statements = sql_generator_class.executable_remove_statements(interface)
    
    statements.each { |statement| execute statement }
  end

  private

  def sql_generator_class
    db_adapter = ActiveRecord::Base.configurations[Rails.env]['adapter']
    unless SUPPORTED_ADAPTERS.include?(db_adapter)
      raise DatabaseAdapterError.new(db_adapter)
    end
    "Fides::#{db_adapter.capitalize}Writer".constantize
  end

  def interface_name(model_name)
    associations = model_name.constantize.reflect_on_all_associations
    associations.select { |r| r.options[:polymorphic] }.first.name
  end
end

class ActiveRecord::Migration
  include Fides
end