require_relative '../test_helper'
 
describe Fides::PostgresqlWriter do

  let(:subject) { Fides::PostgresqlWriter }

  it 'responds to #executable_add_statements' do
    assert_respond_to subject, :executable_add_statements
  end

  it 'responds to #executable_remove_statements' do
    assert_respond_to subject, :executable_remove_statements
  end

  it 'returns an expected add constraints SQL string' do
    sql = subject.executable_add_statements("imageable", ["Product", "Employee"], "Picture")[0]
    assert_equal subject.strip_non_essential_spaces(add_constraints_sql), sql
  end

  it 'returns an expected drop constraints SQL string' do
    sql = subject.executable_remove_statements("imageable")[0]
    assert_equal subject.strip_non_essential_spaces(drop_constraing_sql), sql 
  end

  let(:add_constraints_sql) do %{

      DROP FUNCTION IF EXISTS check_imageable_create_integrity() CASCADE;

      CREATE FUNCTION check_imageable_create_integrity() RETURNS TRIGGER AS '
        BEGIN
          IF NEW.imageable_type = ''Product'' AND EXISTS (
            SELECT id FROM products WHERE id = NEW.imageable_id) THEN
            RETURN NEW;
          ELSEIF NEW.imageable_type = ''Employee'' AND EXISTS (
            SELECT id FROM employees WHERE id = NEW.imageable_id) THEN
            RETURN NEW;
          ELSE
            RAISE EXCEPTION ''No % model with id %.'', NEW.imageable_type, NEW.imageable_id;
            RETURN NULL;
          END IF;
        END'
      LANGUAGE plpgsql;

      CREATE TRIGGER check_imageable_create_integrity_trigger
        BEFORE INSERT OR UPDATE ON pictures
        FOR EACH ROW EXECUTE PROCEDURE check_imageable_create_integrity();CREATE FUNCTION check_imageable_delete_integrity() RETURNS TRIGGER AS '
        BEGIN
          IF TG_TABLE_NAME = ''products'' AND EXISTS (
            SELECT id FROM pictures
            WHERE imageable_type = ''Product'' AND imageable_id = OLD.id) THEN
            RAISE EXCEPTION ''There are records in pictures that refer to %. You must delete those records first.'', OLD;
          ELSEIF TG_TABLE_NAME = ''employees'' AND EXISTS (
            SELECT id FROM pictures
            WHERE imageable_type = ''Employee'' AND imageable_id = OLD.id) THEN
            RAISE EXCEPTION ''There are records in pictures that refer to %. You must delete those records first.'', OLD;
          ELSE
            RETURN NULL;
          END IF;
        END'
      LANGUAGE plpgsql;

      CREATE TRIGGER check_products_delete_integrity_trigger
        BEFORE DELETE ON products
        FOR EACH ROW EXECUTE PROCEDURE check_imageable_delete_integrity();

      CREATE TRIGGER check_employees_delete_integrity_trigger
        BEFORE DELETE ON employees
        FOR EACH ROW EXECUTE PROCEDURE check_imageable_delete_integrity();

    }
  end

  let(:drop_constraing_sql) do %{
      DROP FUNCTION IF EXISTS check_imageable_create_integrity() CASCADE;
      DROP FUNCTION IF EXISTS check_imageable_delete_integrity() CASCADE;
    }
  end

end