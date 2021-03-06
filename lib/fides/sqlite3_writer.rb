require 'fides/sql_writer'

module Fides
  class Sqlite3Writer
    include SqlWriter

    def self.executable_add_statements(interface, models, polymorphic_model)
      statements = []
      statements << drop_sql(interface, "create")
      statements << create_sql(interface, models, polymorphic_model)
      models.each do |model|
        statements << drop_sql(model.constantize.table_name, "delete")
        statements << delete_sql(interface, model, polymorphic_model)
      end
      statements << drop_sql(interface, "update")
      statements << update_sql(interface, models, polymorphic_model)
      statements
    end

    def self.executable_remove_statements(interface)
      statements = []
      statements << drop_sql(interface, "create")
      statements << drop_sql(interface, "delete")
      statements
    end

    private

    def self.drop_sql(name, drop_type)
      strip_non_essential_spaces "DROP TRIGGER IF EXISTS 
                                  check_#{name}_#{drop_type}_integrity;"
    end

    def self.create_sql(interface, models, polymorphic_model)
        sql = %{

        CREATE TRIGGER check_#{interface}_create_integrity
          BEFORE INSERT ON #{polymorphic_model.constantize.table_name}
          BEGIN 
            SELECT CASE 
        }

      sql << 'WHEN ('

      models.each do |model|  
        sql << %{NEW.#{interface}_type != '#{model}' }
        sql << 'AND ' unless model == models.last
      end

      sql << %{) THEN RAISE(ABORT, 'There is no model by that name.') }

      models.each do |model|
        sql << %{ 
          WHEN ((NEW.#{interface}_type = '#{model}') AND (SELECT id 
            FROM #{model.constantize.table_name} 
            WHERE id = NEW.#{interface}_id) ISNULL) 
            THEN RAISE(ABORT, 'There is no #{model} with that id.') 
        }
      end

      sql << "END; END;"

      strip_non_essential_spaces(sql)
    end

      def self.update_sql(interface, models, polymorphic_model)
        sql = %{

        CREATE TRIGGER check_#{interface}_update_integrity
          BEFORE UPDATE ON #{polymorphic_model.constantize.table_name}
          BEGIN 
            SELECT CASE 
        }

      sql << 'WHEN ('

      models.each do |model|  
        sql << %{NEW.#{interface}_type != '#{model}' }
        sql << 'AND ' unless model == models.last
      end

      sql << %{) THEN RAISE(ABORT, 'There is no model by that name.') }

      models.each do |model|
        sql << %{ 
          WHEN ((NEW.#{interface}_type = '#{model}') AND (SELECT id 
            FROM #{model.constantize.table_name} 
            WHERE id = NEW.#{interface}_id) ISNULL) 
            THEN RAISE(ABORT, 'There is no #{model} with that id.') 
        }
      end

      sql << "END; END;"

      strip_non_essential_spaces(sql)
    end

    def self.delete_sql(interface, associated_model, polymorphic_model)
      sql = %{

        CREATE TRIGGER 
          check_#{associated_model.constantize.table_name}_delete_integrity
          BEFORE DELETE ON #{associated_model.constantize.table_name}
          BEGIN
            SELECT CASE
              WHEN ((SELECT id FROM #{polymorphic_model.constantize.table_name} 
                WHERE #{interface}_type = '#{associated_model}' 
                AND #{interface}_id = OLD.id) NOTNULL) THEN 
                  RAISE(ABORT, 
                    'There are records in the 
                    #{polymorphic_model.constantize.table_name} 
                    table that refer to the 
                    #{associated_model.constantize.table_name} record that is 
                    attempting to be deleted. Delete the dependent records in 
                    the #{polymorphic_model.constantize.table_name} table 
                    first.')
            END;
          END;

      }

      strip_non_essential_spaces(sql)
    end
  end
end