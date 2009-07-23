require 'test/unit'
require 'test/unit/ui/console/testrunner'

# Use our custom TestRunner in place of the default console runner.
# SeleniumTestRunner extends console TestRunner. Main difference is screendumps and snapshots.
# You'd think there would be a easier, cleaner way to do this.
#
# Holds class-based reference to Selenium driver
module Test
  module Unit
    module UI
      class SeleniumTestRunner < Test::Unit::UI::Console::TestRunner
        def self.selenium(options)
          @@selenium = Selenium::Client::Driver.new(options)
        end
        
        def initialize(suite, output_level=NORMAL, io=STDOUT)
          super(suite, output_level=NORMAL, io=STDOUT)
        end

        def add_fault(fault)
          dir, path = screenshot_path_for(fault)
          File.open("tmp/acceptance.html", "a") do |f|
            f.puts "<p><em>#{fault.long_display}</em></p>"
            f.puts "<a href='../#{path}'>Screenshot</a><br/>"
            f.puts "<a href='../#{html_path_for(fault)}'>HTML</a>"
          end

          FileUtils.mkdir_p dir
          File.open(path, "wb") { |f| f.write Base64.decode64(@@selenium.capture_entire_page_screenshot_to_string("")) }

          if @@selenium.session_started?
            File.open(html_path_for(fault), "w") { |f| f.write @@selenium.get_html_source }
          end

          super
        end
        
        def test_started(name)
          File.open("tmp/acceptance.html", "a") do |f|
            f.puts "<p>#{name}</p>"
          end
          super
        end
        
        def started(result)
          File.open("tmp/acceptance.html", "w") do |f|
            f.puts "<html>"
            f.puts "<body>"
          end
          super
        end
        
        def finished(elapsed_time)
          File.open("tmp/acceptance.html", "a") do |f|
            f.puts "</body>"
            f.puts "</html>"
          end
          super
        end
        
        def screenshot_path_for(fault)
          # /test/acceptance/public_pages_test.rb:27:in `test_popular_pages'
          dir = "tmp#{fault.location.first[/(\/[^.]+)/,1]}"
          path = "#{dir}/#{fault.location.first[/`([^\']+)/,1]}.png"
          [dir, path]
        end
        
        def html_path_for(fault)
          dir = "tmp#{fault.location.first[/(\/[^.]+)/,1]}"
          "#{dir}/#{fault.location.first[/`([^\']+)/,1]}.html"
        end
      end
    end
  end
end
