require 'fides/sql_writer'

module Fides

  class Sqlite3Writer
    include SqlWriter

    def self.executable_add_statements(interface_name, models, polymorphic_model)
      statements = []
      statements << drop_constraint_sql(interface_name, "create")
      statements << create_constraint_sql(interface_name, models, polymorphic_model)
      models.each do |model|
        statements << drop_constraint_sql(model.constantize.table_name, "delete")
        statements << delete_constraint_sql(interface_name, model, polymorphic_model)
      end
      statements << drop_constraint_sql(interface_name, "update")
      statements << update_constraint_sql(interface_name, models, polymorphic_model)
      return statements
    end

    def self.executable_remove_statements(interface_name)
      statements = []
      statements << drop_constraint_sql(interface_name, "create")
      statements << drop_constraint_sql(interface_name, "delete")
      return statements
    end

    private

    def self.drop_constraint_sql(name, drop_type)
      strip_non_essential_spaces "DROP TRIGGER IF EXISTS check_#{name}_#{drop_type}_integrity;"
    end

    def self.create_constraint_sql(interface_name, models, polymorphic_model)
        sql = %{

        CREATE TRIGGER check_#{interface_name}_create_integrity
          BEFORE INSERT ON #{polymorphic_model.constantize.table_name}
          BEGIN 
            SELECT CASE 
        }

      models.each do |model|
        sql << %{ 
          WHEN ((NEW.#{interface_name}_type = '#{model}') AND (SELECT id 
            FROM #{model.constantize.table_name} WHERE id = NEW.#{interface_name}_id) ISNULL) 
            THEN RAISE(ABORT, 'There is no #{model} with that id.') 
        }
      end

      sql << "END; END;"

      return strip_non_essential_spaces(sql)
    end

      def self.update_constraint_sql(interface_name, models, polymorphic_model)
        sql = %{

        CREATE TRIGGER check_#{interface_name}_update_integrity
          BEFORE UPDATE ON #{polymorphic_model.constantize.table_name}
          BEGIN 
            SELECT CASE 
        }

      models.each do |model|
        sql << %{ 
          WHEN ((NEW.#{interface_name}_type = '#{model}') AND (SELECT id 
            FROM #{model.constantize.table_name} WHERE id = NEW.#{interface_name}_id) ISNULL) 
            THEN RAISE(ABORT, 'There is no #{model} with that id.') 
        }
      end

      sql << "END; END;"

      return strip_non_essential_spaces(sql)
    end

    def self.delete_constraint_sql(interface_name, associated_model, polymorphic_model)
      sql = %{

        CREATE TRIGGER check_#{associated_model.constantize.table_name}_delete_integrity
          BEFORE DELETE ON #{associated_model.constantize.table_name}
          BEGIN
            SELECT CASE
              WHEN ((SELECT id FROM #{polymorphic_model.constantize.table_name} 
                WHERE #{interface_name}_type = '#{associated_model}' AND #{interface_name}_id = OLD.id) NOTNULL) THEN 
                  RAISE(ABORT, 'There are records in the #{polymorphic_model.constantize.table_name} table that refer to the #{associated_model.constantize.table_name} record that is attempting to be deleted. Delete the dependent records in the #{polymorphic_model.constantize.table_name} table first.')
            END;
          END;

      }

      return strip_non_essential_spaces(sql)
    end

  end

end