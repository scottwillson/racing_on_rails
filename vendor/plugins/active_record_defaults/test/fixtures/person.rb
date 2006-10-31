class Person < ActiveRecord::Base
  defaults :city => 'Christchurch', :country => Proc.new { 'New Zealand' }
  
  defaults :first_name => 'Sean'
  
  default :last_name do
    'Fitzpatrick'
  end
  
  defaults :lucky_number => lambda { 2 }
  
  default :birthdate do |person|
    Date.new(2006, 10, person.lucky_number) if person.lucky_number?
  end
end
