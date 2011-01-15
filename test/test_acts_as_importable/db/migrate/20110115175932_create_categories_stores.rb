class CreateCategoriesStores < ActiveRecord::Migration
  def self.up
    create_table :categories_stores, :force => true, :id => false do |t|
      t.references :category
      t.references :store
    end
  end

  def self.down
    drop_table :categories_stores
  end
end