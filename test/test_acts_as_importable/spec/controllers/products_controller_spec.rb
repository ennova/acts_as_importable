require 'spec_helper'

describe ProductsController do

  describe "POST 'upload'" do
    it "should redirect to import" do
      post 'upload'
      response.should redirect_to "/products/import"
    end
  end

  describe "GET 'import'" do
    before do
      @store = Store.create!(:name => 'iTunes Store')
    end

    it "should render import form" do
      get 'import'
      response.should be_success
      response.should render_template("import")
    end

    it "should pass a :scoped context value to model.import" do
      product = Product.create!(:name => "iPhone 4", :price => 399.99)
      filename = create_test_file("products", [product])
      Product.expects(:import).with(filename, has_entry(:scoped => @store))
      get 'import'
    end

    it "should create new products from csv file" do
      product1 = Product.new(:name => "iPhone 4", :price => 399.99)
      product2 = Product.new(:name => "iPhone 3GS", :price => 299.99)
      create_test_file("products", [product1, product2])

      expect{ get 'import' }.to change{ Product.count }.from(0).to(2)
    end

    it "should create new records scoped to the store" do
      product1 = Product.new(:name => "iPhone 4", :price => 399.99)
      product2 = Product.new(:name => "iPhone 3GS", :price => 299.99)
      create_test_file("products", [product1, product2])

      expect{ get 'import' }.to change{ @store.products.count }.from(0).to(2)
    end
  end

  describe "GET 'export'" do
    it "should send csv file" do
      get 'export'
      response.headers["Content-Type"].should == "text/csv; charset=iso-8859-1; header=present"
      response.headers["Content-Disposition"].should include("attachment")
    end
  end

  private
  def create_test_file(controller_name, products)
    FileUtils.mkdir_p(UPLOADS_PATH)
    filename = "#{UPLOADS_PATH}/#{controller_name}.csv"
    FasterCSV.open(filename, "w") do |csv|
      csv << ["name", "price"]
      products.each do |p|
        csv << [p.name, p.price]
      end
    end
    return filename
  end
end
