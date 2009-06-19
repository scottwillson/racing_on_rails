class PersonSession < Authlogic::Session::Base
  remember_me true
  remember_me_for 3.months
end
