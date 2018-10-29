# frozen_string_literal: true

require "rails/test_unit/runner"

namespace :test do
  desc "Start server and run browser-based acceptance tests"
  task acceptance: ["db:test:prepare"] do
    test_files = FileList["tests_isolated/acceptance/**/*_test.rb"]
    Rails::TestUnit::Runner.run test_files
  end
end
