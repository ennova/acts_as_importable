# ImportExport
module ImportExport
module ControllerMethods
  
  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    # any method placed here will apply to classes
    def acts_as_importable(model_class_name = nil)
      cattr_accessor :model_class
      if model_class_name
        self.model_class = model_class_name.to_s.classify.constantize
      else
        self.model_class = self.controller_name.singularize.classify.constantize
      end
      send :include, InstanceMethods
    end
  end
  
  module InstanceMethods
    def export
      send_data self.class.model_class.export, :type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment; filename=#{export_file_name}"   
    end
    
    def import
      @new_objects = []
      filename = "#{UPLOADS_PATH}/#{self.controller_name}.csv"

      if File.exists? filename
        begin
          @new_objects = self.class.model_class.import(filename)
          flash[:notice] = "Import Successful - #{@new_objects.length} New #{self.class.model_class.name.underscore.humanize.pluralize}"
        rescue Exception => e
          logger.error e.backtrace
          flash[:error] = "Error: Unable to process file. #{e}"
        ensure
          File.delete(filename)
        end
      else
        @new_objects = []
      end
      render :template => "import_export/import"
    end
    
    def upload
      require 'ftools'
      if params[:csv_file] && File.extname(params[:csv_file].original_filename) == '.csv'
        File.makedirs "#{UPLOADS_PATH}"
        File.open("#{UPLOADS_PATH}/#{self.controller_name}.csv", "wb") { |f| f.write(params[:csv_file].read)}
        flash[:notice] = "Successful import of #{self.controller_name} data file"
      else
        flash[:error] = "Error! Invalid file, please select a csv file."
      end
      redirect_to "/#{self.controller_name}/import"
    end
    
    private
    
    def export_file_name
      "#{Time.now.to_formatted_s(:number)}_#{self.controller_name}_export.csv"
    end
  
  end # end of module InstanceMethods

end # end of module ControllerMethods
end