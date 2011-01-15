class ProductsController < ApplicationController
  acts_as_importable :product, :scoped => :current_store, :find_existing_by => :name

  protected
  def current_store
    Store.first
  end
end
