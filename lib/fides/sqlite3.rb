require 'fides/sql_writer'

module Fides

  class Sqlite3
    include SqlWriter

    def self.get_create_function_sql(interface_name, models, polymorphic_model)
      sql = %{

        DROP TRIGGER IF EXISTS check_#{interface_name}_create_integrity;

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

    def self.get_delete_function_sql(interface_name, models, polymorphic_model)
      sql = ""

      models.each do |model|
        sql << %{

          DROP TRIGGER IF EXISTS check_#{model.constantize.table_name}_delete_integrity;

          CREATE TRIGGER check_#{model.constantize.table_name}_delete_integrity
            BEFORE DELETE ON #{model.constantize.table_name}
            BEGIN
              SELECT CASE
                WHEN ((SELECT id FROM #{polymorphic_model.constantize.table_name} 
                  WHERE imageable_type = '#{model}' AND imageable_id = OLD.id) NOTNULL) THEN 
                    RAISE(ABORT, 'There are records in the #{polymorphic_model.constantize.table_name} table that refer to the #{model.constantize.table_name} record that is attempting to be deleted. Delete the dependent records in the #{polymorphic_model.constantize.table_name} table first.')
              END;
            END;

        }
      end

      return strip_non_essential_spaces(sql)
    end

    def self.get_drop_function_sql(interface_name)
      sql = %{
        DROP TRIGGER IF EXISTS check_#{interface_name}_create_integrity;
        DROP TRIGGER IF EXISTS check_#{interface_name}_delete_integrity;
      }
      return strip_non_essential_spaces(sql)
    end

  end

end