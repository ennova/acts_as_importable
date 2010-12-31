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
end
