require 'import_export/csv'

# ImportExport
module ImportExport
module ModelMethods
  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    # any method placed here will apply to classes
    def acts_as_importable(options = {})
      cattr_accessor :import_fields, :export_fields, :before_parse, :before_import, :formats, :csv_options
      self.import_fields = options[:import_fields]
      self.export_fields = options[:export_fields]
      self.before_parse = options[:before_parse]
      self.before_import = options[:before_import]
      self.formats = options[:formats]
      self.csv_options = options[:csv_options] || {}
      send :include, InstanceMethods
    end

    def import(filename, context)
      collection = []
      scope_object = context[:scoped]
      format = context[:format]

      # method to modify file before parsing
      if self.before_parse
        before_parse_method = format.blank? ? self.before_parse : "#{self.before_parse}_#{format}"
        if self.respond_to? before_parse_method
          self.send(before_parse_method, filename, context)
        else
          raise "undefined before_parse method '#{before_parse_method}' for #{self} class"
        end
      end

      data = self.read_csv(filename)
      ActiveRecord::Base.transaction do
        data.each_with_index do |data_row, index|
          # data_row.map{|d| d.strip! if d}

          # method to modify data_row before import
          if self.before_import
            before_import_method = format.blank? ? self.before_import : "#{self.before_import}_#{format}"
            if self.respond_to? before_import_method
              self.send(before_import_method, data_row, context)
            else
              raise "undefined before_import method '#{before_import_method}' for #{self} class"
            end
          end

          # Skip blank rows which could be blank in csv file or blanked out by the before_import method.
          if data_row.is_a?(CSV::Row)
            next if data_row.to_hash.values.all?{ |v| v.blank? }
          else
            next if data_row.all?{ |v| v.blank? }
          end

          begin
            class_or_association = scope_object ? scope_object.send(self.table_name) : self
            if key_field = context[:find_existing_by]
              key_value = data_row[index_of(key_field)]
              element = class_or_association.send("find_by_#{key_field}", key_value) || class_or_association.new
            else
              element = class_or_association.new
            end

            Rails.logger.info "#{element.new_record? ? "Creating new" : "Updating existing"} record from #{data_row.inspect}"

            self.import_fields.each_with_index do |field_name, field_index|
              if field_name.include?('.')
                assign_association(element, field_name, field_index, context, data_row)
              else
                element.send "#{field_name}=", data_row[field_index]
              end
            end

            element.save!
            collection << element
          rescue Exception => e
            e1 = e.exception("Invalid data found at line #{index + 2} : " + e.message)
            e1.set_backtrace(e.backtrace)
            Rails.logger.error e1.message
            Rails.logger.error e1.backtrace.join("\n")
            raise e1
          end
        end
      end
      return collection
    end

    def export
      export_fields = self.import_fields || self.export_fields
      ImportExport::CSV.generate do |csv|
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
        ImportExport::CSV.parse(File.open(filename, 'rb'), self.csv_options)
      else
        raise ArgumentError, "File does not exist."
      end
    end

    def index_of(fieldname)
      @import_field_indices ||= {}
      @import_field_indices[fieldname] ||= self.import_fields.index{ |f| f.to_s == fieldname.to_s }
    end

    protected

    def assign_association(element, field_name, field_index, context, data_row)
      scope_object = context[:scoped]
      format = context[:format]
      create_record = field_name.include?('!')
      association_name, association_attribute = field_name.gsub(/!/,'').split('.')
      assign_association_method = format.blank? ? "assign_#{association_name}" : "assign_#{association_name}_#{format}"
      association_fk = "#{association_name}_id"

      if element.respond_to?(assign_association_method)
        element.send assign_association_method, data_row, context
      elsif element.respond_to?(association_fk)
        association_class = association_name.classify.constantize

        if scope_object && scope_object.respond_to?(association_class.table_name)
          association_class = scope_object.send(association_class.table_name)
        end

        finder_method = "find_by_#{association_attribute}"
        if association_class and association_class.respond_to?(finder_method)
          e = association_class.send(finder_method, data_row[field_index])
          if e.nil? and create_record and !data_row[field_index].blank?
            e = association_class.create!(association_attribute => data_row[field_index])
          end
          element[association_fk] = e.id if e
        end
      end
    end
  end

  module InstanceMethods
    def index_of(fieldname)
      self.class.index_of(fieldname)
    end
  end

end
end