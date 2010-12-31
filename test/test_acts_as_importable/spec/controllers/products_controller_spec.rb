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
  end

  describe "GET 'export'" do
    it "should send csv file" do
      get 'export'
      response.headers["Content-Type"].should == "text/csv; charset=iso-8859-1; header=present"
      response.headers["Content-Disposition"].should include("attachment")
    end
  end

end
