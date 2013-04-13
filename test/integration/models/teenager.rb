class Teenager < ActiveRecord::Base
  has_many :clothing_articles, :as => :wearable
end