class CreateAccessories < ActiveRecord::Migration
  def self.up
    create_table :accessories do |t|
      t.string :name
      t.decimal :price
      t.references :store
      t.timestamps
    end
  end

  def self.down
    drop_table :accessories
  end
end
