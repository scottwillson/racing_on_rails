# Load site-specific controllers and let them re-open their corresponding class
module Dependencies
  def require_or_load(file_name)
    file_name = "#{file_name}.rb" unless ! load? || file_name[-3..-1] == '.rb'
    load? ? load(file_name) : require(file_name)
    if file_name.include? 'controller'
      file_name = File.join('local', 'app', 'controllers', File.basename(file_name))
      if File.exist? file_name
        load? ? load(file_name) : require(file_name)
      end
    end
  end
end

# Prefer site-specific templates, partials etc. if they exist.  Otherwise, use the base
# application's generic files.
module ActionView
  class Base
    private
      def full_template_path(template_path, extension)
        # Check to see if the partial exists in our 'sites' folder first
        site_specific_path = File.join(RAILS_ROOT, 'local', 'app', 'views', "#{template_path}.#{extension}")
        if File.exist?(site_specific_path)
          site_specific_path
        else
          "#{@base_path}/#{template_path}.#{extension}"
        end
      end
  end
end
# Scoop up both the base's migration files (those that should apply to ALL sites), plus
# the site-specific migration files.  Sort them.  Apply them in turn.
module ActiveRecord
  class Migrator
  private
    def migration_files
      generic_files = Dir["#{@migrations_path}/[0-9]*_*.rb"].sort
      puts generic_files.inspect
      # Include the site-specific files in our complete list of migration files
      if defined? 'local' and File.exist?("local/db/migrate")
        # Note that a tilde (~) is used intentionally because its ascii value
        # is greater than both the lower-case and upper-case alphabets (thereby
        # causing the sort! below to behave as expected).
        site_specific_files = Dir["local/db/migrate/[0-9]*\.[0-9]*_*.rb"]
        files = generic_files + site_specific_files
        # Sort by filename, ignoring the path to get there.  Also convert '.'
        # to '~' so that sorting occurs in the correct order.
        files.sort! { |a,b| a.gsub(".", "~").match(/.+[\/\\](.+)/)[1] <=> b.gsub(".", "~").match(/.+[\/\\](.+)/)[1] }
      else
        files = generic_files
      end
      down? ? files.reverse : files
    end

  end
end

# Make routes site-specific for sites whose config/routes.rb exists
module ActionController
  module Routing #:nodoc:
    class RouteSet
      def replace(*args)
        new_route = Route.new(*args)
        # Remove the old route that we're replacing
        @routes.delete_if { |r| r.path == args[0] }
        # Add the new one back
        @routes << new_route
        return new_route
      end

      def draw_append
        yield self
        write_generation
        write_recognition
      end

      # Get both the base routes.rb file AND the site-specific routes.rb file
      def reload
        NamedRoutes.clear

        loaded_routes = false

        # Load the initial set of routes for the base application
        if defined?(RAILS_ROOT) and File.exist?(File.join(RAILS_ROOT, 'config', 'routes.rb'))
          load(File.join(RAILS_ROOT, 'config', 'routes.rb'))
          loaded_routes = true
        end

        # Add on site-specific routes
        if File.exist?(File.join(RAILS_ROOT, 'local', 'config', 'routes.rb'))
          load(File.join(RAILS_ROOT, 'local', 'config', 'routes.rb'))
          loaded_routes = true
        end

        # Use a sensible default if nothing could be loaded
        unless loaded_routes
          connect(':controller/:action/:id', :action => 'index', :id => nil)
        end

        NamedRoutes.install
      end
    end
  end
end

module ActionController #:nodoc:
  module Helpers #:nodoc:
    module ClassMethods
      def helper(*args, &block)
        args.flatten.each do |arg|
          case arg
            when Module
              add_template_helper(arg)
            when String, Symbol
              file_name  = arg.to_s.underscore + '_helper'
              class_name = file_name.camelize
                
              begin
                require_dependency(file_name)
              rescue LoadError => load_error
                requiree = / -- (.*?)(\.rb)?$/.match(load_error).to_a[1]
                msg = (requiree == file_name) ? "Missing helper file helpers/#{file_name}.rb" : "Can't load file: #{requiree}"
                raise LoadError.new(msg).copy_blame!(load_error)
              end

              add_template_helper(class_name.constantize)
            else
              raise ArgumentError, 'helper expects String, Symbol, or Module argument'
          end
          super
        end

        # Evaluate block in template class if given.
        master_helper_module.module_eval(&block) if block_given?
      end
    end
  end
end
# Load any site-specific models
# TODO: Make site-specific models re-open classes rather than
# this temporary either/or hack
$:.concat(Dir["local/app/models/[_a-z]*"])

# Local config customization
load("#{RAILS_ROOT}/local/config/environment.rb") if File.exist?("#{RAILS_ROOT}/local/config/environment.rb")
ActionController::Routing::Routes.reload

module ActionController #:nodoc:
  module Helpers #:nodoc:
    module ClassMethods
      def helper(*args, &block)
        args.flatten.each do |arg|
          case arg
            when Module
              load("#{RAILS_ROOT}/local/app/helpers/#{arg.to_s.underscore}.rb") if File.exist?("#{RAILS_ROOT}/local/app/helpers/#{arg.to_s.underscore}.rb")
              master_helper_module.send(:include, arg)
            when String, Symbol
              file_name  = arg.to_s.underscore + '_helper'
              class_name = file_name.camelize
                
              begin
                require_dependency(file_name)
              rescue LoadError => load_error
                requiree = / -- (.*?)(\.rb)?$/.match(load_error).to_a[1]
                msg = (requiree == file_name) ? "Missing helper file helpers/#{file_name}.rb" : "Can't load file: #{requiree}"
                raise LoadError.new(msg).copy_blame!(load_error)
              end

              add_template_helper(class_name.constantize)
            else
              raise ArgumentError, 'helper expects String, Symbol, or Module argument'
          end
        end

        # Evaluate block in template class if given.
        master_helper_module.module_eval(&block) if block_given?
      end
    end
  end
end
