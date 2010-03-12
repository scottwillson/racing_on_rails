require 'test/unit'
require 'test/unit/ui/console/testrunner'

# Use our custom TestRunner in place of the default console runner.
# WebDriverRunner extends console TestRunner. Main difference is screendumps and snapshots.
# You'd think there would be a easier, cleaner way to do this.
#
# Holds class-based reference to WebDriver driver
module Test
  module Unit
    module UI
      class WebDriverTestRunner < Test::Unit::UI::Console::TestRunner
        @@driver = nil
        
        def self.driver=(value)
          @@driver = value
        end
        
        def results_path
          File.expand_path("#{RAILS_ROOT}/log/acceptance")
        end
        
        def initialize(suite, output_level=NORMAL, io=STDOUT)
          super(suite, output_level=NORMAL, io=STDOUT)
        end

        def add_fault(fault)
          dump(fault)
          super
        end

        def add_error(fault)
          dump(fault)
          super
        end
        
        def dump(fault)
          dir, path = screenshot_path_for(fault)
          File.open("#{results_path}/index.html", "a") do |f|
            f.puts "<h2>#{fault.test_name}</h2>"
            f.puts "<h3>#{fault.message}</h3>"
            if fault.respond_to? :location
              f.puts "<ol>"
              fault.location.each do |line|
                f.puts "<li>#{line}</li>"
              end
              f.puts "</ol>"
            elsif fault.respond_to? :exception
              f.puts "<ol>"
              fault.exception.backtrace.each do |line|
                f.puts "<li>#{line}</li>"
              end
              f.puts "</ol>"
            end
            File.open("#{results_path}/index.html", "a") do |f|
              f.puts "<a href='./#{fault.test_name[/[^\(]+\(([^\)]+)/,1]}/#{fault.test_name[/[^\(]+/]}.png'>Screenshot</a><br/>"
              f.puts "<a href='./#{fault.test_name[/[^\(]+\(([^\)]+)/,1]}/#{fault.test_name[/[^\(]+/]}.html'>HTML</a>"
            end
          end

          begin
            if @@driver
              FileUtils.mkdir_p dir
              @@driver.save_screenshot(path)
              File.open(html_path_for(fault), "w") { |f| f.write @@driver.page_source }
            end
          rescue Exception => e
            p e
            e.backtrace.each do |line|
              p line
            end
          end
        end
        
        def test_started(name)
          File.open("#{results_path}/index.html", "a") do |f|
            f.puts "<p>#{name}</p>"
          end
          super
        end
        
        def started(result)
          FileUtils.rm_rf results_path
          FileUtils.mkdir_p results_path
          File.open("#{results_path}/index.html", "w") do |f|
            f.puts "<html>"
            f.puts "<body>"
          end
          super
        end
        
        def finished(elapsed_time)
          File.open("#{results_path}/index.html", "a") do |f|
            f.puts "</body>"
            f.puts "</html>"
          end
          super
        end
        
        def screenshot_path_for(fault)
          dir = "#{results_path}/#{fault.test_name[/[^\(]+\(([^\)]+)/,1]}"
          path = "#{dir}/#{fault.test_name[/[^\(]+/]}.png"
          [ dir, path ]
        end
        
        def html_path_for(fault)
          "#{results_path}/#{fault.test_name[/[^\(]+\(([^\)]+)/,1]}/#{fault.test_name[/[^\(]+/]}.html"
        end
      end
    end
  end
end
