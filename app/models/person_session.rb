# Login session
class PersonSession < Authlogic::Session::Base
  remember_me true
  remember_me_for 2.weeks
end
