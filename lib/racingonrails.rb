def prepend_to_load_path(path)
  abs_path = File.expand_path(File.dirname(__FILE__) + path)
  $:.unshift(abs_path) unless $:.include?(abs_path) 
end

prepend_to_load_path('/racingonrails/app/controllers')
prepend_to_load_path('/racingonrails/app/helpers')
prepend_to_load_path('/racingonrails/app/models')
prepend_to_load_path('/racingonrails/app/models/schedule')
prepend_to_load_path('/racingonrails/lib')

module RacingOnRails
end

include RacingOnRails
include RacingOnRails::Schedule
