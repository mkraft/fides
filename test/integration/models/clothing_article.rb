class ClothingArticle < ActiveRecord::Base
  belongs_to :wearable, :polymorphic => true
end