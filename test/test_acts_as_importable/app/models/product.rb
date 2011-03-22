class Product < ActiveRecord::Base
  belongs_to :store
  belongs_to :category
  serialize :discount, Hash

  acts_as_importable :import_fields => ["name", "price", "category.name", "discount.percentage"],
                     :before_import => :modify_name

  protected
  def assign_discount(data_row, context)
    store = context[:scoped]
    self.discount = {:type => "#{store.try(:name)} End of Season Sale".strip, :percentage => data_row[index_of("discount.percentage")]}
  end

  # class method which gets called on every row in csv file.
  # Current row from csv file is passed as parameter, which can be modified here before object import.
  # data_row is an array which represent a row in csv file.
  def self.modify_name(data_row)
    data_row[0] = "Modified Name" if data_row[0] == "Modify Name"
  end
end
