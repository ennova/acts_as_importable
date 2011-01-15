# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  # config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true
end

module ImportHelperMethods
  def create_test_file(products)
    FileUtils.mkdir_p(UPLOADS_PATH)
    filename = File.join(UPLOADS_PATH, self.class.metadata[:type] == :controller ? "products_#{request.session_options[:id]}.csv" : "products.csv" )
    FasterCSV.open(filename, "w") do |csv|
      csv << ["name", "price"]
      products.each do |p|
        csv << [p.name, p.price]
      end
    end
    return filename
  end
end
