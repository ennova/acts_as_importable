class ProductsController < ApplicationController
  acts_as_importable :product, :scoped => :current_store

  protected
  def current_store
    Store.first
  end
end
