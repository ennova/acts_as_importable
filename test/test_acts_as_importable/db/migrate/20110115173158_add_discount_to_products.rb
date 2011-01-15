class AddDiscountToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :discount, :string
  end

  def self.down
    remove_column :products, :discount
  end
end