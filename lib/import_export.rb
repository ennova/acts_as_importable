# ImportExport
module ImportExport
module ModelMethods
  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    # any method placed here will apply to classes
    def acts_as_importable(options = {})
      cattr_accessor :import_fields, :export_fields
      self.import_fields = options[:import_fields]
      self.export_fields = options[:export_fields]
      send :include, InstanceMethods
    end
    
    def import(filename)

      collection = []
      headers, *data  = self.read_csv(filename)

      ActiveRecord::Base.transaction do
        data.each_with_index do |data_row, index|
          data_row.map{|d| d.strip! if d}
          Rails.logger.info data_row.inspect

          begin
            element = self.new

            self.import_fields.each_with_index do |field_name, field_index|
              if field_name.include?('.')
                method_name = 'assign_' + field_name.split('.')[0]
                if element.respond_to?(method_name)
                  element.send method_name, data_row
                elsif element.respond_to?("#{field_name.split('.')[0]}_id")
                  create_record = field_name.include?('!')
                  split_field = field_name.gsub(/!/,'').split('.').compact
                  initial_class = split_field[0].classify.constantize
                  if initial_class and initial_class.respond_to?("find_by_#{split_field[1]}")
                    begin
                      e = initial_class.send("find_by_#{split_field[1]}", data_row[field_index])
                    rescue
                      e = nil
                    end
                    # try to create a new record if not found in database and if '!' is present
                    if e.nil? and create_record and !data_row[field_index].blank?
                      e = initial_class.create!("#{split_field[1]}" => data_row[field_index])
                    end
                    if e.kind_of?(ActiveRecord::Base)
                      element["#{split_field[0]}_id"] = e.id
                    end
                  else
                    e = nil
                  end
                end
              else
                element.send "#{field_name}=", data_row[field_index]
              end
            end

            element.save!
            collection << element
          rescue Exception => e
            Rails.logger.error e
            Rails.logger.error e.backtrace
            raise "Invalid data found at line #{index + 2}. #{e}"
          end

        end
      end
      return collection
    end

    def export
      puts self.inspect
      export_fields = self.import_fields || self.export_fields
      FasterCSV.generate do |csv|
        csv << export_fields.map{|f| f.split('.')[0]}

        self.find_each(:batch_size => 2000) do |element|
          collection = []
          export_fields.each do |field_name|
            begin
              if field_name.include?('.')
                method_names = field_name.gsub(/!/,'').split('.').compact
                sub_element = element
                method_names.each do |method_name|
                  if sub_element || sub_element.respond_to?(method_name)
                    sub_element = sub_element.send(method_name)
                  else
                    break
                  end
                end
                collection << sub_element
              else
                collection << element.send(field_name)
              end
            rescue Exception => e
              Rails.logger.info ">>>>>>>>> Exception Caught ImportExport >>>>>>>>>>>"
              Rails.logger.error e.message
              Rails.logger.error e.backtrace
              collection << nil
            end
          end
          csv << collection
        end
        
      end
    end

    def read_csv(filename)
      if File.exist?(filename)
        begin
          collection = FasterCSV.parse(File.open(filename, 'rb'))
        rescue FasterCSV::MalformedCSVError => e
          raise e
        end

        collection = collection.map{|w| w} unless collection.nil?
        collection = [] if collection.nil?

        return collection
      else
        raise ArgumentError, "File does not exist."
      end
    end
  end

  module InstanceMethods
    # any method placed here will apply to instaces, like @hickwall
  end

end
end