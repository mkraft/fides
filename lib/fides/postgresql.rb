module Fides

  class Postgresql
    include SqlWriter

    def self.get_create_function_sql(interface_name, models, polymorphic_model)

      sql = "DROP FUNCTION IF EXISTS check_#{interface_name}_create_integrity() CASCADE;"

      sql << %{
        CREATE FUNCTION check_#{interface_name}_create_integrity() RETURNS TRIGGER AS '
          BEGIN
            IF NEW.#{interface_name}_type = ''#{models[0]}'' AND EXISTS (
                SELECT id FROM #{models[0].constantize.table_name} WHERE id = NEW.#{interface_name}_id) THEN
              RETURN NEW;
      }

      models[1..-1].each do |model|
        sql << %{
          ELSEIF NEW.#{interface_name}_type = ''#{model}'' AND EXISTS (
              SELECT id FROM #{model.constantize.table_name} WHERE id = NEW.#{interface_name}_id) THEN
            RETURN NEW;
        }
      end
      
      sql << %{
            ELSE
              RAISE EXCEPTION ''No % model with id %.'', NEW.#{interface_name}_type, NEW.#{interface_name}_id;
              RETURN NULL;
            END IF;
          END'
          LANGUAGE plpgsql;

          CREATE TRIGGER check_#{interface_name}_create_integrity_trigger 
            BEFORE INSERT OR UPDATE ON #{polymorphic_model.constantize.table_name} 
            FOR EACH ROW EXECUTE PROCEDURE check_#{interface_name}_create_integrity();
      }

      return strip_non_essential_spaces(sql)
    end

    def self.get_delete_function_sql(interface_name, models, polymorphic_model)
      polymorphic_model_table_name = polymorphic_model.constantize.table_name
      
      sql = ""
      sql << %{
        CREATE FUNCTION check_#{interface_name}_delete_integrity() RETURNS TRIGGER AS '
          BEGIN
            IF TG_TABLE_NAME = ''#{models[0].constantize.table_name}'' AND EXISTS (
              SELECT id FROM #{polymorphic_model_table_name} 
              WHERE #{interface_name}_type = ''#{models[0]}'' AND #{interface_name}_id = OLD.id) THEN
              RAISE EXCEPTION ''There are records in #{polymorphic_model_table_name} that refer to %. You must delete those records first.'', OLD;
      }

      models[1..-1].each do |model|
        sql << %{
          ELSEIF TG_TABLE_NAME = ''#{model.constantize.table_name}'' AND EXISTS (
            SELECT id FROM #{polymorphic_model_table_name} 
            WHERE #{interface_name}_type = ''#{model}'' AND #{interface_name}_id = OLD.id) THEN
              RAISE EXCEPTION ''There are records in #{polymorphic_model_table_name} that refer to %. You must delete those records first.'', OLD;
        }
      end

      sql << %{
            ELSE
              RETURN NULL;
            END IF;
          END'
        LANGUAGE plpgsql;
      }

      models.each do |model|
        table_name = model.constantize.table_name
        
        sql << %{
          CREATE TRIGGER check_#{table_name}_delete_integrity_trigger 
            BEFORE DELETE ON #{table_name} 
            FOR EACH ROW EXECUTE PROCEDURE check_#{interface_name}_delete_integrity();
        }
      end

      return strip_non_essential_spaces(sql)
    end

    def self.get_drop_function_sql(interface_name)
      sql = %{
        DROP FUNCTION IF EXISTS check_#{interface_name}_create_integrity() CASCADE;
        DROP FUNCTION IF EXISTS check_#{interface_name}_delete_integrity() CASCADE;
      }
      return strip_non_essential_spaces(sql)
    end

  end #class

end #module