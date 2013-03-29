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

end