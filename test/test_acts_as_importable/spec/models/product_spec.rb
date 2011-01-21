require 'spec_helper'

describe Product do
  it "should be able to create new Product" do
    Product.create!(:name => "iPhone 4", :price => 399.00)
  end

  it "should have import method" do
    Product.should respond_to(:import)
  end

  it "should know index of import field at class level" do
    Product.index_of(:name).should == 0
    Product.index_of(:price).should == 1
    Product.index_of('category.name').should == 2
  end

  it "should know index of import field at instance level" do
    Product.new.index_of(:name).should == 0
    Product.new.index_of(:price).should == 1
    Product.new.index_of('category.name').should == 2
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
      filename = create_test_file([product1, product2])

      expect{ Product.import(filename, {}) }.to change{ Product.count }.from(0).to(2)
    end

    it "should create new products attached to category if category.name is specified in the csv file" do
      mobiles = Category.create!(:name => 'Mobiles')
      tablets = Category.create!(:name => 'Tablets')
      product1 = Product.new(:name => "iPhone 4", :price => 399.99, :category => mobiles)
      product2 = Product.new(:name => "iPad", :price => 599.99, :category => tablets)
      product3 = Product.new(:name => "iPod", :price => 99.99)
      filename = create_test_file([product1, product2, product3])

      expect{ Product.import(filename, {}) }.to change{ Product.count }.from(0).to(3)
      Product.find_by_name(product1.name).category.should == mobiles
      Product.find_by_name(product2.name).category.should == tablets
      Product.find_by_name(product3.name).category.should be_nil
    end

    it "should create new products with discount percentage if discount.percentage is specified in the csv file" do
      product1 = Product.new(:name => "iPhone 4", :price => 399.99, :discount => {:percentage => '10'})
      product2 = Product.new(:name => "iPhone 3GS", :price => 299.99)
      filename = create_test_file([product1, product2])

      expect{ Product.import(filename, {:scoped => @store}) }.to change{ Product.count }.from(0).to(2)
      Product.find_by_name(product1.name).discount[:type].should == "#{@store.name} End of Season Sale"
      Product.find_by_name(product1.name).discount[:percentage].should == '10'
    end

    it "should create new products scoped to the store" do
      product1 = Product.new(:name => "iPhone 4", :price => 399.99)
      product2 = Product.new(:name => "iPhone 3GS", :price => 299.99)
      filename = create_test_file([product1, product2])

      expect{ Product.import(filename, {:scoped => @store}) }.to change{ @store.products.count }.from(0).to(2)
    end

    it "should create new products with categories scoped to given store" do
      mobiles = Category.create!(:name => 'Mobiles')
      tablets = Category.create!(:name => 'Tablets')

      @store.categories << [mobiles, tablets]
      store2 = Store.create!(:name => 'Apple Store, Bangalore')
      store2.categories << [mobiles]

      product1 = Product.new(:name => "iPhone 3G", :price => 199.99, :category => mobiles)
      product2 = Product.new(:name => "iPad", :price => 199.99, :category => tablets) # category not applicable to store2

      filename = create_test_file([product1, product2])

      expect{ Product.import(filename, {:scoped => store2})}.to change{ Product.count }.from(0).to(2)
      Product.find_by_name(product1.name).category.should == mobiles
      Product.find_by_name(product2.name).category.should be_nil
    end

    it "should update existing products using the field specified by :find_existing_by" do
      product1 = Product.create!(:name => "iPhone 3G", :price => 199.99)
      product2 = Product.create!(:name => "iPhone 3GS", :price => 199.99)
      product3 = Product.new(:name => "iPhone 4", :price => 399.99)

      product2.price = 299.99 # new value to be updated
      filename = create_test_file([product1, product2])

      expect{ Product.import(filename, {:find_existing_by => :price}) }.to change{ product2.price }.by(0)
      expect{ Product.import(filename, {:find_existing_by => :name}) }.to change{ product2.reload.price }.from(199.99).to(299.99)
    end

    it "should update only existing products in given store" do
      store2 = Store.create!(:name => 'Mac Store')
      product2a = store2.products.create!(:name => "iPhone 3GS", :price => 199.99) # existing product in another store

      product1 = @store.products.create!(:name => "iPhone 3G", :price => 199.99)
      product2 = @store.products.create!(:name => "iPhone 3GS", :price => 199.99) # existing product to be updated
      product3 = Product.new(:name => "iPhone 4", :price => 399.99)

      product2.price = 299.99 # new value to be updated
      filename = create_test_file([product1, product2])

      expect{ Product.import(filename, {:scoped => @store, :find_existing_by => :name}) }.to change{ product2.reload.price }.from(199.99).to(299.99)
      product2a.reload.price.should == 199.99
    end
  end
end
