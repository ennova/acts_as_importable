class Product < ActiveRecord::Base
  belongs_to :store
  acts_as_importable :import_fields => ["name", "price"]
end
