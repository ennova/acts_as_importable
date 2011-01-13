require 'spec_helper'

describe Product do
  it "should be able to create new Product" do
    Product.create!(:name => "iPhone 4", :price => 399.00)
  end

  it "should have import method" do
    Product.should respond_to(:import)
  end

  it "should have export method" do
    Product.should respond_to(:export)
  end

  describe "import" do
    include ImportHelperMethods

    before do
      @store = Store.create!(:name => 'iTunes Store')
    end

    it "should create new products from csv file" do
      product1 = Product.new(:name => "iPhone 4", :price => 399.99)
      product2 = Product.new(:name => "iPhone 3GS", :price => 299.99)
      filename = create_test_file("products", [product1, product2])

      expect{ Product.import(filename, {}) }.to change{ Product.count }.from(0).to(2)
    end

    it "should create new products scoped to the store" do
      product1 = Product.new(:name => "iPhone 4", :price => 399.99)
      product2 = Product.new(:name => "iPhone 3GS", :price => 299.99)
      filename = create_test_file("products", [product1, product2])

      expect{ Product.import(filename, {:scoped => @store}) }.to change{ @store.products.count }.from(0).to(2)
    end

    it "should update existing products using first import field as key" do
      product1 = Product.create!(:name => "iPhone 3G", :price => 199.99)
      product2 = Product.create!(:name => "iPhone 3GS", :price => 199.99)
      product3 = Product.new(:name => "iPhone 4", :price => 399.99)

      product2.price = 299.99 # new value to be updated
      filename = create_test_file("products", [product1, product2])

      expect{ Product.import(filename, {}) }.to change{ product2.reload.price }.from(199.99).to(299.99)
    end

    it "should update only existing products in given store" do
      store2 = Store.create!(:name => 'Mac Store')
      product2a = store2.products.create!(:name => "iPhone 3GS", :price => 199.99) # existing product in another store

      product1 = @store.products.create!(:name => "iPhone 3G", :price => 199.99)
      product2 = @store.products.create!(:name => "iPhone 3GS", :price => 199.99) # existing product to be updated
      product3 = Product.new(:name => "iPhone 4", :price => 399.99)

      product2.price = 299.99 # new value to be updated
      filename = create_test_file("products", [product1, product2])

      expect{ Product.import(filename, {:scoped => @store}) }.to change{ product2.reload.price }.from(199.99).to(299.99)
      product2a.reload.price.should == 199.99
    end
  end
end
