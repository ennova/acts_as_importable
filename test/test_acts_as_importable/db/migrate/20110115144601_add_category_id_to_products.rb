class AddCategoryIdToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :category_id, :integer
  end

  def self.down
    remove_column :products, :category_id
  end
end
