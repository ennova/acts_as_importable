class Product < ActiveRecord::Base
  belongs_to :store
  belongs_to :category
  serialize :discount, Hash

  acts_as_importable :import_fields => ["name", "price", "category.name", "discount.percentage"]

  protected
  def assign_discount(data_row, context)
    store = context[:scoped]
    self.discount = {:type => "#{store.try(:name)} End of Season Sale".strip, :percentage => data_row[index_of("discount.percentage")]}
  end
end
