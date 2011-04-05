class Product < ActiveRecord::Base
  belongs_to :store
  belongs_to :category
  serialize :discount, Hash

  acts_as_importable :import_fields => ["name", "price", "category.name", "discount.percentage"],
                     :before_parse => :strip_non_header_lines,
                     :before_import => :modify_name,
                     :csv_options => { :headers => true }

  protected
  def assign_discount(data_row, context)
    store = context[:scoped]
    self.discount = {:type => "#{store.try(:name)} End of Season Sale".strip, :percentage => data_row[index_of("discount.percentage")]}
  end

  # class method which gets called on every row in csv file.
  # Current row from csv file is passed as parameter, which can be modified here before object import.
  # data_row is a CSV::Row which represent a row in csv file.
  def self.modify_name(data_row, context)
    data_row[0] = "Modified Name" if data_row[0] == "Modify Name"
  end

  # The csv file is passed as parameter, which can be modified here before it's parsed.
  def self.strip_non_header_lines(file, context)
    temp_file = Tempfile.new(file)
    begin
      File.open file do |io|
        io.readline # skip first line
        while !io.eof?; temp_file.write io.read(1024) ; end
      end
      FileUtils.mv temp_file, file, :force => true
    ensure
      temp_file.close!
    end
  end
end
