# frozen_string_literal: true

require "rails/test_unit/runner"

namespace :test do
  task :ruby do
    test_files = FileList["tests_isolated/ruby/**/*_test.rb"]
    Rails::TestUnit::Runner.run test_files
  end
end
