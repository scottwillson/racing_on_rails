require 'rake/testtask'

namespace :test do
  Rake::TestTask.new("ruby") do |t|
    t.test_files = FileList['test/ruby/**/*_test.rb'].shuffle
    t.verbose = true
  end

  task :run do
    errors = %w(test:ruby test:units test:functionals test:integration).collect do |task|
      begin
        Rake::Task[task].invoke
        nil
      rescue => e
        { :task => task, :exception => e }
      end
    end.compact

    if errors.any?
      puts errors.map { |e| "Errors running #{e[:task]}! #{e[:exception].inspect}" }.join("\n")
      abort
    end
  end
end
