require 'spec_helper'

describe Accessory do

  describe "import" do
    include ImportHelperMethods

    it "should create new accessories from csv file" do
      accessory1 = Accessory.new(:name => "iphone:Case", :price => 29.99)
      accessory2 = Accessory.new(:name => "iphone:Screen Guard", :price => 9.99)
      filename = create_accessories_csv([accessory1, accessory2])

      expect{ Accessory.import(filename, {:format => 'iphone_format'})}.to change{ Accessory.count }.by(2)
    end

    it "should replace missing prices with zeroes before importing accessories from csv file" do
      accessory1 = Accessory.new(:name => "iphone:Case", :price => '-')
      accessory2 = Accessory.new(:name => "iphone:Screen Guard", :price => '')
      filename = create_accessories_csv([accessory1, accessory2])

      expect{ Accessory.import(filename, {:format => 'iphone_format'})}.to change{ Accessory.count }.by(2)

      Accessory.find_by_name("Case").price.should == 0
      Accessory.find_by_name("Screen Guard").price.should == 0
    end

    it "should create new accessories from csv file in iphone format" do
      accessory1 = Accessory.new(:name => "iphone:Case", :price => 29.99)
      accessory2 = Accessory.new(:name => "iphone:Screen Guard", :price => 9.99)
      filename = create_accessories_csv([accessory1, accessory2])

      expect{ Accessory.import(filename, {:format => 'iphone_format'})}.to change{ Accessory.count }.by(2)

      # Format handling logic should strip prefix e.g. "iphone:Case" should become "Case"
      Accessory.find_by_name("Case").should_not be_nil
      Accessory.find_by_name("Screen Guard").should_not be_nil
    end

    it "should create new accessories from csv file in ipad format" do
      accessory1 = Accessory.new(:name => "ipad:Case", :price => 39.99)
      accessory2 = Accessory.new(:name => "ipad:Screen Guard", :price => 19.99)
      filename = create_accessories_csv([accessory1, accessory2])

      expect{ Accessory.import(filename, {:format => 'ipad_format'})}.to change{ Accessory.count }.by(2)

      # Format handling logic should strip prefix e.g. "ipad:Case" should become "Case"
      Accessory.find_by_name("Case").should_not be_nil
      Accessory.find_by_name("Screen Guard").should_not be_nil
    end
  end
end
