require_relative '../../test_helper'
 
describe Fides do

  it "responds to add_polymorphic_triggers" do
    assert_respond_to ActiveRecord::Migration, :add_polymorphic_triggers
  end

  it "responds to remove_polymorphic_triggers" do
    assert_respond_to ActiveRecord::Migration, :remove_polymorphic_triggers
  end
 
end