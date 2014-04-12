namespace :test do
  Rails::TestTask.new(:ruby) do |t|
    t.pattern = 'test/{ruby}/**/*_test.rb'
  end
end
