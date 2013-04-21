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
    raise ArgumentError, "missing :associated_models from options hash" if !opts.has_key?(:associated_models) 
    raise ArgumentError, "missing :polymorphic_model from options hash" if !opts.has_key?(:polymorphic_model)

    associated_models = opts[:associated_models]
    polymorphic_model = opts[:polymorphic_model]
    interface = opts.has_key?(:interface_name) ? opts[:interface_name] : interface_name(polymorphic_model)

    execution_statements = get_sql_generator_class.executable_add_statements(interface, associated_models, polymorphic_model)
    execution_statements.each { |statement| execute statement }
  end

  def remove_polymorphic_triggers(opts)
    raise ArgumentError, "missing :polymorphic_model from options hash" if !opts.has_key?(:polymorphic_model)
    
    polymorphic_model = opts[:polymorphic_model]
    interface = opts.has_key?(:interface_name) ? opts[:interface_name] : interface_name(polymorphic_model)

    execution_statements = get_sql_generator_class.executable_remove_statements(interface)
    execution_statements.each { |statement| execute statement }
  end

  private

  def get_sql_generator_class
    db_adapter = ActiveRecord::Base.configurations[Rails.env]['adapter']
    raise DatabaseAdapterError.new(db_adapter) unless SUPPORTED_ADAPTERS.include?(db_adapter)
    return "Fides::#{db_adapter.capitalize}Writer".constantize
  end

  def interface_name(model_name)
    model_name.constantize.reflect_on_all_associations.select { |r| r if r.options[:polymorphic] }.first.name
  end

end

class ActiveRecord::Migration
  include Fides
end
