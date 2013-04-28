class AddTriggers < ActiveRecord::Migration
  def up
    add_polymorphic_triggers(:polymorphic_model => "ClothingArticle", :associated_models => ["Baby", "Senior", "Teenager"])
  end

  def down
    remove_polymorphic_triggers(:polymorphic_model => "ClothingArticle")
  end
end