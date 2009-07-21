require "test_helper"
require "selenium/client"
require "test/unit/ui/console/testrunner"

class PublicPagesTest < ActiveSupport::TestCase
	attr_reader :browser
   
  def setup
    @browser = Selenium::Client::Driver.new \
        :host => "localhost", 
        :port => 4444, 
        :browser => "*firefox", 
        :url => "http://www.google.com", 
        :timeout_in_second => 60

    browser.start_new_browser_session
  end
    
  def teardown
    browser.close_current_browser_session
  end
  
  def test_popular_pages
    browser.open "/"
  end
end

module Test
  module Unit
    module UI
      module Console
        class TestRunner
          def start_with_screendump
            mediator = start_without_screendump
            mediator.add_listener(TestResult::FAULT, &method(:capture_page_screenshot))
            # mediator.add_listener(TestRunnerMediator::STARTED, &method(:started))
            # mediator.add_listener(TestRunnerMediator::FINISHED, &method(:finished))
            # mediator.add_listener(TestCase::STARTED, &method(:test_started))
            # mediator.add_listener(TestCase::FINISHED, &method(:test_finished))
            mediator
          end
          
          def capture_page_screenshot
            return unless @selenium_driver.chrome_backend? && @selenium_driver.session_started?

            encodedImage = @selenium_driver.capture_entire_page_screenshot_to_string("")
            pngImage = Base64.decode64(encodedImage)
            File.open(@file_path_strategy.file_path_for_page_screenshot(@example), "wb") { |f| f.write pngImage }
          end
          
          alias_method_chain :start, :screendump
        end
      end
    end
  end
end
