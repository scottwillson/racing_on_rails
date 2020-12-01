# frozen_string_literal: true

require "rails/test_unit/runner"

namespace :test do
  desc "Test calculations"
  task calculations: :ruby do
    $LOAD_PATH << "test"
    test_files = FileList["test/models/calculations/v3/**/*_test.rb"]
    Rails::TestUnit::Runner.run test_files
  end

  task ruby: :environment do
    test_files = FileList["test_ruby/**/*_test.rb"]
    Rails::TestUnit::Runner.run test_files
  end
end
