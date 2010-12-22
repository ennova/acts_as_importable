require 'spec_helper'

build_model :products do
  string :name
  decimal :price
  acts_as_importable
end

class ProductsController < ActionController::Base
  acts_as_importable
end

ActionDispatch::Routing::RouteSet.new.draw do
  resources :products do
    collection do
      get 'import'
      post 'upload'
    end
  end
end

# TODO: Make this work
# describe ProductsController do
#   describe "GET import" do
#     it "responds with import template" do
#       get "products/import"
#       response.should render_template("import_export/import")
#     end
#   end
# end
