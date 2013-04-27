require_relative '../test_helper'
 
describe Fides::Sqlite3Writer do

  let(:subject) { Fides::Sqlite3Writer }

  it 'responds to #executable_add_statements' do
    assert_respond_to subject, :executable_add_statements
  end

  it 'responds to #executable_remove_statements' do
    assert_respond_to subject, :executable_remove_statements
  end

  it 'returns expected create constrains statements' do
    statements = subject.executable_add_statements("imageable", ["Product", "Employee"], "Picture")
    statements.each_with_index do |statement, index|
      assert_equal subject.strip_non_essential_spaces( send("add_sql#{index + 1}") ), statement
    end
  end

  it 'returns expected drop constrains statements' do
    sql1 = subject.executable_remove_statements("imageable")[0]
    sql2 = subject.executable_remove_statements("imageable")[1]
    assert_equal subject.strip_non_essential_spaces(drop_sql1), sql1
    assert_equal subject.strip_non_essential_spaces(drop_sql2), sql2
  end

  let(:add_sql1) do %{
    DROP TRIGGER IF EXISTS check_imageable_create_integrity;
    }
  end

  let(:add_sql2) do %{
    CREATE TRIGGER check_imageable_create_integrity
      BEFORE INSERT ON pictures
      BEGIN 
        SELECT CASE
          WHEN (NEW.imageable_type != 'Product' AND NEW.imageable_type != 'Employee' ) THEN RAISE(ABORT, 'There is no model by that name.')
          WHEN ((NEW.imageable_type = 'Product') AND (SELECT id FROM products WHERE id = NEW.imageable_id) ISNULL) THEN RAISE(ABORT, 'There is no Product with that id.')
          WHEN ((NEW.imageable_type = 'Employee') AND (SELECT id FROM employees WHERE id = NEW.imageable_id) ISNULL) THEN RAISE(ABORT, 'There is no Employee with that id.')
        END;
      END;
    }
  end

  let(:add_sql3) do %{
    DROP TRIGGER IF EXISTS check_products_delete_integrity;
    }
  end
  
  let(:add_sql4) do %{
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

  let(:add_sql5) do %{
    DROP TRIGGER IF EXISTS check_employees_delete_integrity;
    }
  end

  let(:add_sql6) do %{
      CREATE TRIGGER check_employees_delete_integrity
        BEFORE DELETE ON employees
        BEGIN
          SELECT CASE
            WHEN ((SELECT id FROM pictures WHERE imageable_type = 'Employee' AND imageable_id = OLD.id) NOTNULL) THEN 
              RAISE(ABORT, 'There are records in the pictures table that refer to the employees record that is attempting to be deleted. Delete the dependent records in the pictures table first.')
          END;
        END;
    }
  end

  let(:add_sql7) do %{
    DROP TRIGGER IF EXISTS check_imageable_update_integrity;
    }
  end

  let(:add_sql8) do %{
    CREATE TRIGGER check_imageable_update_integrity
      BEFORE UPDATE ON pictures
      BEGIN 
        SELECT CASE
          WHEN ((NEW.imageable_type = 'Product') AND (SELECT id FROM products WHERE id = NEW.imageable_id) ISNULL) THEN RAISE(ABORT, 'There is no Product with that id.')
          WHEN ((NEW.imageable_type = 'Employee') AND (SELECT id FROM employees WHERE id = NEW.imageable_id) ISNULL) THEN RAISE(ABORT, 'There is no Employee with that id.')
        END;
      END;
    }
  end

  let(:drop_sql1) do %{
      DROP TRIGGER IF EXISTS check_imageable_create_integrity;
    }
  end

  let(:drop_sql2) do %{
      DROP TRIGGER IF EXISTS check_imageable_delete_integrity;
    }
  end

end