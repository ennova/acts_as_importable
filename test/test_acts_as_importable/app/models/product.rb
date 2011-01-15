class Product < ActiveRecord::Base
  belongs_to :store
  belongs_to :category
  acts_as_importable :import_fields => ["name", "price", "category.name"]
end
