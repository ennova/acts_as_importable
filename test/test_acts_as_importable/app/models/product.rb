class Product < ActiveRecord::Base
  acts_as_importable :import_fields => ["name", "price"]
end
