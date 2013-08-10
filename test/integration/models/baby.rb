class Baby < ActiveRecord::Base
  self.table_name = 'babies'
  has_many :clothing_articles, as: :wearable, dependent: :destroy
end