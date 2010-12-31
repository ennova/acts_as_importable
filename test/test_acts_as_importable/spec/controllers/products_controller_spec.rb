require 'spec_helper'

describe ProductsController do

  describe "POST 'upload'" do
    it "should redirect to import" do
      post 'upload'
      response.should redirect_to "/products/import"
    end
  end

  describe "GET 'import'" do
    it "should render import form" do
      get 'import'
      response.should be_success
      response.should render_template("import")
    end

    it "should pass a :scoped context value to model.import" do
      store = Store.create!(:name => 'iTunes Store')
      filename = create_test_file("products")
      Product.expects(:import).with(filename, has_entry(:scoped => store))
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

  private
  def create_test_file(controller_name)
    filename = "#{UPLOADS_PATH}/#{controller_name}.csv"
    File.open(filename, "w") do |f|
    end
    return filename
  end
end
