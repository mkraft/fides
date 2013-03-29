require_relative '../test_helper'
 
describe Fides do

  before do
    class Picture < ActiveRecord::Base
      def self.reflect_on_all_associations
        [MyTestAssociaiton.new]
      end
    end
    class Product < ActiveRecord::Base; end
    class Employee < ActiveRecord::Base; end
    class MyTestMigration < ActiveRecord::Migration
      def execute(blah)
      end
    end
    class MyTestAssociaiton
      def options
        {:polymorphic => true}
      end
      def name
        @imageable
      end
    end
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
      @my_test_migration.add_polymorphic_triggers(:polymorphic_model => "Picture") 
    }
    assert_match /associated_models/, exception.message
  end

  it "raises and exception if :polymorphic_model isn't a parameter of #add_polymorphic_triggers" do
    exception = assert_raises(ArgumentError) { 
      @my_test_migration.add_polymorphic_triggers(:associated_models => ["Product", "Employee"]) 
    }
    assert_match /polymorphic_model/, exception.message
  end

  it "raise an error if the database adapter isn't supported" do
    Rails.stub :env, "development" do
      ActiveRecord::Base.stub :configurations, { "development" => { "adapter" => "fakedb" } } do
        exception = assert_raises(Fides::DatabaseAdapterError) { 
          @my_test_migration.add_polymorphic_triggers(
            :polymorphic_model => "Picture", 
            :associated_models => ["Product", "Employee"]
          )
        }
        assert_match /fakedb/, exception.message
      end
    end
  end

  it "runs silently" do
    assert_silent do
      Rails.stub :env, "development" do
        ActiveRecord::Base.stub :configurations, { "development" => { "adapter" => "postgresql" } } do
          @my_test_migration.add_polymorphic_triggers(
            :polymorphic_model => "Picture", 
            :associated_models => ["Product", "Employee"],
            :interface_name => "imageable"
          )
        end
      end
    end
  end

end