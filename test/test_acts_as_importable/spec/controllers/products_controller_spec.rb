require 'spec_helper'

describe ProductsController do
  include ImportHelperMethods

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
      filename = create_test_file([product])
      Product.expects(:import).with(filename, has_entry(:scoped => @store)).returns([])
      get 'import'
    end

    it "should pass a :find_existing_by value to allow import to lookup existing records for update" do
      product = Product.create!(:name => "iPhone 4", :price => 399.99)
      filename = create_test_file([product])
      Product.expects(:import).with(filename, has_entry(:find_existing_by => :name)).returns([])
      get 'import'
    end
  end

  describe "GET 'export'" do
    it "should send csv file" do
      get 'export'
      response.headers["Content-Type"].should == "text/csv; charset=iso-8859-1; header=present"
      response.headers["Content-Disposition"].should include("attachment")
    end
  end
end
