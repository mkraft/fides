require_relative '../../test_helper'
 
describe Fides::Sqlite3 do

  let(:subject) { Fides::Sqlite3 }

  it 'responds to #get_create_function_sql' do
    assert_respond_to subject, :get_create_function_sql
  end

  it 'responds to #get_delete_function_sql' do
    assert_respond_to subject, :get_delete_function_sql
  end

  it 'responds to #get_drop_function_sql' do
    assert_respond_to subject, :get_drop_function_sql
  end

  it 'returns an expected create SQL string' do
    sql = subject.get_create_function_sql("imageable", ["Product", "Employee"], "Picture")
    assert_equal subject.strip_non_essential_spaces(create_sql), sql
  end

  it 'returns an expected delete SQL string' do
    sql = subject.get_delete_function_sql("imageable", ["Employee", "Product"], "Picture")
    assert_equal subject.strip_non_essential_spaces(delete_sql), sql 
  end

  it 'returns an expected drop SQL string' do
    sql = subject.get_drop_function_sql("imageable")
    assert_equal subject.strip_non_essential_spaces(drop_sql), sql
  end

  let(:create_sql) do %{

      DROP TRIGGER IF EXISTS check_imageable_create_integrity;

      CREATE TRIGGER check_imageable_create_integrity
        BEFORE INSERT ON pictures
        BEGIN 
          SELECT CASE
            WHEN ((NEW.imageable_type = 'Product') AND (SELECT id FROM products WHERE id = NEW.imageable_id) ISNULL) THEN RAISE(ABORT, 'There is no Product with that id.')
            WHEN ((NEW.imageable_type = 'Employee') AND (SELECT id FROM employees WHERE id = NEW.imageable_id) ISNULL) THEN RAISE(ABORT, 'There is no Employee with that id.')
          END;
        END;

    }
  end

  let(:delete_sql) do %{

    DROP TRIGGER IF EXISTS check_employees_delete_integrity;

    CREATE TRIGGER check_employees_delete_integrity
      BEFORE DELETE ON employees
      BEGIN
        SELECT CASE
          WHEN ((SELECT id FROM pictures WHERE imageable_type = 'Employee' AND imageable_id = OLD.id) NOTNULL) THEN 
            RAISE(ABORT, 'There are records in the pictures table that refer to the employees record that is attempting to be deleted. Delete the dependent records in the pictures table first.')
        END;
      END;


    DROP TRIGGER IF EXISTS check_products_delete_integrity;

    CREATE TRIGGER check_products_delete_integrity
      BEFORE DELETE ON products
      BEGIN
        SELECT CASE
          WHEN ((SELECT id FROM pictures WHERE imageable_type = 'Product' AND imageable_id = OLD.id) NOTNULL) THEN 
            RAISE(ABORT, 'There are records in the pictures table that refer to the products record that is attempting to be deleted. Delete the dependent records in the pictures table first.')
        END;
      END;

    }
  end

  let(:drop_sql) do %{
      DROP TRIGGER IF EXISTS check_imageable_create_integrity;
      DROP TRIGGER IF EXISTS check_imageable_delete_integrity;
    }
  end


end