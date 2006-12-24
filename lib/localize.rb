# Local config customization
load("#{RAILS_ROOT}/local/config/environment.rb") if File.exist?("#{RAILS_ROOT}/local/config/environment.rb")

# Prefer local templates, partials etc. if they exist.  Otherwise, use the base
# application's generic files.
module ActionView
  class Base
    private
      def full_template_path(template_path, extension)
        # Check to see if the partial exists in our 'local' folder first
        local_path = File.join(RAILS_ROOT, 'local', 'app', 'views', "#{template_path}.#{extension}")
        if File.exist?(local_path)
          local_path
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
