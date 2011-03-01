# ImportExport
module ImportExport
  module ControllerMethods

    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods
      # any method placed here will apply to classes
      def acts_as_importable(model_class_name = nil, context = {})
        cattr_accessor :model_class
        cattr_accessor :context
        if model_class_name
          self.model_class = model_class_name.to_s.classify.constantize
        else
          self.model_class = self.controller_name.singularize.classify.constantize
        end
        self.context = context
        send :include, InstanceMethods
      end
    end

    module InstanceMethods
      def export
        send_data self.class.model_class.export, :type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment; filename=#{export_file_name}"   
      end

      def import
        @new_objects = []
        filename = upload_file_name
        context = self.class.context.clone
        context[:scoped] = self.send(context[:scoped]) if context[:scoped]

        if File.exists? filename
          begin
            @new_objects = self.class.model_class.import(filename, context)
            flash[:notice] = "Import Successful - Imported #{@new_objects.length} #{self.class.model_class.name.underscore.humanize.pluralize}"
          rescue Exception => e
            logger.error flash[:error] = "Import Failed - No records imported due to errors. #{e}"
          ensure
            File.delete(filename)
          end
        else
          @new_objects = []
        end
        render :template => "import_export/import"
      end

      def upload
        if params[:csv_file] && File.extname(params[:csv_file].original_filename) == '.csv'
          File.makedirs "#{UPLOADS_PATH}"
          File.open(upload_file_name, "wb") { |f| f.write(params[:csv_file].read)}
        else
          flash[:error] = "Error! Invalid file, please select a csv file."
        end
        redirect_to "/#{self.controller_name}/import"
      end

      private

      def upload_file_name
        @upload_file_name ||= "#{UPLOADS_PATH}/#{self.controller_name}_#{request.session_options[:id]}.csv"
      end

      def export_file_name
        @export_file_name ||= "#{Time.now.to_formatted_s(:number)}_#{self.controller_name}_export.csv"
      end

    end # end of module InstanceMethods

  end # end of module ControllerMethods
end