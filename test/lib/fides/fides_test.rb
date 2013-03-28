require_relative '../../test_helper'
 
describe Fides do

  before do
    class Picture < ActiveRecord::Base; end
    class MyTestMigration < ActiveRecord::Migration; end
    class MyTestAssociaiton
      def options
        { :polymorphic => true }
      end

      def name
        "imageable"
      end
    end
    @my_test_association = MyTestAssociaiton.new
    @my_test_migration = MyTestMigration.new
  end

  it "responds to add_polymorphic_triggers" do
    assert_respond_to @my_test_migration, :add_polymorphic_triggers
  end

  it "responds to remove_polymorphic_triggers" do
    assert_respond_to @my_test_migration, :remove_polymorphic_triggers
  end

  it "includes the ability to use of the constantize method" do

    assert_equal "Picture".constantize, Picture
  end


  it "raises and exception if :associated_models isn't a parameter of #add_polymorphic_triggers" do
    exception = assert_raises(ArgumentError) { 
      MyTestMigration.add_polymorphic_triggers(:polymorphic_model => "Picture") 
    }
    assert_match /associated_models/, exception.message
  end

  it "raises and exception if :polymorphic_model isn't a parameter of #add_polymorphic_triggers" do
    exception = assert_raises(ArgumentError) { 
      MyTestMigration.add_polymorphic_triggers(:associated_models => ["Product", "Employee"]) 
    }
    assert_match /polymorphic_model/, exception.message
  end

 
end