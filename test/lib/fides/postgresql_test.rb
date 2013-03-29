require_relative '../../test_helper'
 
describe Fides::Postgresql do

  let(:subject) { Fides::Postgresql }

  it 'responds to #get_create_function_sql' do
    assert_respond_to subject, :get_create_function_sql
  end

  it 'responds to #get_delete_function_sql' do
    assert_respond_to subject, :get_delete_function_sql
  end

  it 'responds to #get_drop_function_sql' do
    assert_respond_to subject, :get_drop_function_sql
  end

  it 'returns an expected SQL string' do
    sql = subject.get_create_function_sql("imageable", ["Product", "Employee"], "Picture")
    assert_equal subject.strip_non_essential_spaces(CREATE_SQL), sql
  end

  it 'returns an expected SQL string' do
    sql = subject.get_delete_function_sql("imageable", ["Product", "Employee"], "Picture")
    assert_equal subject.strip_non_essential_spaces(DELETE_SQL), sql 
  end

  CREATE_SQL = %{

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
      FOR EACH ROW EXECUTE PROCEDURE check_imageable_create_integrity();

  }

  DELETE_SQL = %{

    CREATE FUNCTION check_imageable_delete_integrity() RETURNS TRIGGER AS '
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