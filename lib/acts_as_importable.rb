require "active_record"
require "action_controller"
require "fastercsv"

require 'import_export'
ActiveRecord::Base.send :include, ImportExport::ModelMethods

# require 'import_export/routing'
# ActionC::Routing::RouteSet::Mapper.send :include, ImportExport::Routing

require 'import_export/controller_methods'
ActionController::Base.send :include, ImportExport::ControllerMethods