require_relative '../test_helper'

module Fides
  def self.run_common_tests(adapter)
    execute_migration(adapter) do
      CreateTestTables.new.change
      AddTriggers.new.up
    end

    describe "PostgreSQL database interaction behaviour" do
      it "raises an exception inserting a polymorphic without a coresponding record" do
        clothing_article = ClothingArticle.new
        clothing_article.name = "Jeggings"
        clothing_article.wearable_id = 123
        clothing_article.wearable_type = "Teenager"
        assert_raises(ActiveRecord::StatementInvalid) { clothing_article.save }
      end

      it "raises an exception deleting a record that is still referenced by the polymorphic table" do
        senior = Senior.new
        senior.name = "Mr. John"
        senior.save
        senior.reload

        clothing_article = ClothingArticle.new
        clothing_article.name = "Flood pants"
        clothing_article.wearable_id = senior.id
        clothing_article.wearable_type = "Senior"
        clothing_article.save

        assert_raises(ActiveRecord::StatementInvalid) { Senior.find(senior.id).delete }
        assert_raises(ActiveRecord::StatementInvalid) { Senior.find(senior.id).destroy }
      end

      it "doesn't get in the way of :dependent => :destroy" do
        baby = Baby.new
        baby.name = "Suze"
        baby.save
        baby.reload
        
        clothing_article = ClothingArticle.new
        clothing_article.name = "Bloomers"
        clothing_article.wearable_id = baby.id
        clothing_article.wearable_type = "Baby"
        clothing_article.save
        before_destroy_count = ClothingArticle.count
        baby.destroy

        assert_equal (before_destroy_count - 1), ClothingArticle.count
      end

      it "does enfoce dependent destroy behaviour if delete is used instead of destroy" do
        baby = Baby.new
        baby.name = "Suze"
        baby.save
        baby.reload
        
        clothing_article = ClothingArticle.new
        clothing_article.name = "Bloomers"
        clothing_article.wearable_id = baby.id
        clothing_article.wearable_type = "Baby"
        clothing_article.save
        before_destroy_count = ClothingArticle.count

        assert_raises(ActiveRecord::StatementInvalid) { baby.delete }
      end

      it "allows an insert of a model type specified in #add_polymorphic_triggers" do
        baby = Baby.new
        baby.name = "JJ"
        baby.save
        baby.reload
        
        clothing_article = ClothingArticle.new
        clothing_article.name = "Onesie"
        clothing_article.wearable_id = baby.id
        clothing_article.wearable_type = "Baby"
        assert clothing_article.save
      end

      it "allows a delete of a record NOT referenced by the polymorphic table" do
        teenager = Teenager.new
        teenager.name = "Johnny"
        teenager.save
        teenager.reload

        assert Teenager.find(teenager.id).delete
      end

      it "allows a destroy of a record NOT referenced by the polymorphic table" do
        teenager = Teenager.new
        teenager.name = "Johnny"
        teenager.save
        teenager.reload

        assert Teenager.find(teenager.id).destroy
      end

      it "does not allow an insert of a model type that wasn't specified in #add_polymorphic_triggers" do
        clothing_article = ClothingArticle.new
        clothing_article.name = "Nothing"
        clothing_article.wearable_id = 123
        clothing_article.wearable_type = "Zygote"
        
        assert_raises(ActiveRecord::StatementInvalid) { clothing_article.save }
      end

      it "drops the trigger properly" do
        begin
          execute_migration(adapter) do
            AddTriggers.new.down
          end
          clothing_article = ClothingArticle.new
          clothing_article.name = "Nothing"
          clothing_article.wearable_id = 123
          clothing_article.wearable_type = "Zygote"
          
          assert clothing_article.save
        rescue

        ensure
          execute_migration(adapter) do
            AddTriggers.new.up
          end
        end
      end

      it "does not allow an update to a model type that wasn't specified in #add_polymorphic_triggers"
    end # describe
  end # run_common_tests


end # Fides