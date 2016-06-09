namespace :test do
  Rails::TestTask.new(:ruby) do |t|
    t.pattern = 'tests_isolated/ruby/**/*_test.rb'
    t.warning = false
  end
end
