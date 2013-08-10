module Fides
  class PostgresqlWriter
    include SqlWriter

    def self.executable_add_statements(interface, models, polymorphic_model)
      sql = create_and_update_sql(interface, models, polymorphic_model)
      sql << delete_constraint_sql(interface, models, polymorphic_model)
      [sql]
    end

    def self.executable_remove_statements(interface)
      [drop_constraints_sql(interface)]
    end

    private

    def self.create_and_update_sql(interface, models, polymorphic_model)

      sql = "DROP FUNCTION IF EXISTS check_#{interface}_create_integrity() 
            CASCADE;"

      sql << %{
        CREATE FUNCTION check_#{interface}_create_integrity() RETURNS 
        TRIGGER AS '
          BEGIN
            IF NEW.#{interface}_type = ''#{models[0]}'' AND EXISTS (
                SELECT id FROM #{models[0].constantize.table_name} 
                WHERE id = NEW.#{interface}_id) THEN
              RETURN NEW;
      }

      models[1..-1].each do |model|
        sql << %{
          ELSEIF NEW.#{interface}_type = ''#{model}'' AND EXISTS (
              SELECT id FROM #{model.constantize.table_name} 
              WHERE id = NEW.#{interface}_id) THEN
            RETURN NEW;
        }
      end
      
      sql << %{
            ELSE
              RAISE EXCEPTION ''No % model with id %.'', 
              NEW.#{interface}_type, NEW.#{interface}_id;
              RETURN NULL;
            END IF;
          END'
          LANGUAGE plpgsql;

          CREATE TRIGGER check_#{interface}_create_integrity_trigger 
          BEFORE INSERT OR UPDATE ON #{polymorphic_model.constantize.table_name} 
          FOR EACH ROW 
          EXECUTE PROCEDURE check_#{interface}_create_integrity();

      }

      strip_non_essential_spaces(sql)
    end

    def self.delete_constraint_sql(interface, models, polymorphic_model)
      polymorphic_model_table_name = polymorphic_model.constantize.table_name
      
      sql = ""
      sql << %{
        CREATE FUNCTION check_#{interface}_delete_integrity() RETURNS 
        TRIGGER AS '
          BEGIN
            IF TG_TABLE_NAME = ''#{models[0].constantize.table_name}'' AND 
            EXISTS (
              SELECT id FROM #{polymorphic_model_table_name} 
              WHERE #{interface}_type = ''#{models[0]}'' 
              AND #{interface}_id = OLD.id) THEN
              RAISE EXCEPTION ''There are records in 
              #{polymorphic_model_table_name} that refer to %. You must delete 
              those records first.'', OLD;
      }

      models[1..-1].each do |model|
        sql << %{
          ELSEIF TG_TABLE_NAME = ''#{model.constantize.table_name}'' AND EXISTS 
          (
            SELECT id FROM #{polymorphic_model_table_name} 
            WHERE #{interface}_type = ''#{model}'' 
            AND #{interface}_id = OLD.id) THEN
              RAISE EXCEPTION ''There are records in 
              #{polymorphic_model_table_name} that refer to %. You must delete 
              those records first.'', OLD;
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
            FOR EACH ROW EXECUTE PROCEDURE 
            check_#{interface}_delete_integrity();
        }
      end

      strip_non_essential_spaces(sql)
    end

    def self.drop_constraints_sql(interface)
      sql = %{
        DROP FUNCTION IF EXISTS check_#{interface}_create_integrity() 
        CASCADE;
        DROP FUNCTION IF EXISTS check_#{interface}_delete_integrity() 
        CASCADE;
      }
      strip_non_essential_spaces(sql)
    end
  end
end