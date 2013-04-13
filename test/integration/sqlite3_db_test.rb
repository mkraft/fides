# require_relative '../test_helper'

# module Fides
#   migrate_database("sqlite3")

#   describe "PostgreSQL database interaction behaviour" do
#     it "raises an exception inserting a polymorphic without a coresponding record" do
#       clothing_article = ClothingArticle.new
#       clothing_article.name = "Jeggings"
#       clothing_article.wearable_id = 123
#       clothing_article.wearable_type = "Teenager"
#       assert_raises(ActiveRecord::StatementInvalid) { clothing_article.save }
#     end

#     it "raises an exception deleting a record that is still referenced by the polymorphic table" do
#       senior = Senior.new
#       senior.name = "Mr. John"
#       senior.save
#       senior.reload

#       clothing_article = ClothingArticle.new
#       clothing_article.name = "Flood pants"
#       clothing_article.wearable_id = senior.id
#       clothing_article.wearable_type = "Senior"
#       clothing_article.save

#       assert_raises(ActiveRecord::StatementInvalid) { Senior.find(senior.id).delete }
#     end

#     it "allows an insert of a model type specified in #add_polymorphic_triggers" do
#       baby = Baby.new
#       baby.name = "JJ"
#       baby.save
#       baby.reload
      
#       clothing_article = ClothingArticle.new
#       clothing_article.name = "Onesie"
#       clothing_article.wearable_id = baby.id
#       clothing_article.wearable_type = "Baby"
#       assert clothing_article.save
#     end

#     it "allows a delete of a record NOT referenced by the polymorphic table" do
#       teenager = Teenager.new
#       teenager.name = "Johnny"
#       teenager.save
#       teenager.reload

#       assert Teenager.find(teenager.id).delete
#     end

#     # TODO: Should unspecified model types be rejected?
#     it "allows an insert of a model type NOT specified in #add_polymorphic_triggers"
#   end

# end