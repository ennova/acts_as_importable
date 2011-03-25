class Accessory < ActiveRecord::Base
  belongs_to :store

  acts_as_importable :import_fields => ["name.with_prefix", "price"],
                     :before_import => :replace_missing_prices_with_zeroes,
                     :formats => [:iphone_format, :ipad_format]

  protected

  def self.replace_missing_prices_with_zeroes(data_row, context)
    data_row[index_of('price')] = '0' if data_row[index_of('price')].blank?
  end

  class << self
    alias_method :replace_missing_prices_with_zeroes_iphone_format, :replace_missing_prices_with_zeroes
    alias_method :replace_missing_prices_with_zeroes_ipad_format, :replace_missing_prices_with_zeroes
  end

  def assign_name_iphone_format(data_row, context)
    store = context[:scoped]
    self.name = data_row[index_of("name.with_prefix")].split("iphone:").last
  end

  def assign_name_ipad_format(data_row, context)
    store = context[:scoped]
    self.name = data_row[index_of("name.with_prefix")].split("ipad:").last
  end
end
