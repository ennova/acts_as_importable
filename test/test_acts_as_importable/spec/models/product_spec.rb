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

    it "should create new records scoped to the store" do
      product1 = Product.new(:name => "iPhone 4", :price => 399.99)
      product2 = Product.new(:name => "iPhone 3GS", :price => 299.99)
      filename = create_test_file("products", [product1, product2])

      expect{ Product.import(filename, {:scoped => @store}) }.to change{ @store.products.count }.from(0).to(2)
    end
  end
end
