require 'fides/sql_writer'

module Fides

  class Sqlite3
    include SqlWriter

    def self.get_create_function_sql(interface_name, models, polymorphic_model)
      raise "Sqlite3 not yet implemented"
    end

    def self.get_delete_function_sql(interface_name, models, polymorphic_model)
      raise "Sqlite3 not yet implemented"
    end

    def self.get_drop_function_sql(interface_name)
      raise "Sqlite3 not yest implemented"
    end

  end

end