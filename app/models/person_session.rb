# Login session. Remembered for a year.
class PersonSession < Authlogic::Session::Base
  remember_me true
  remember_me_for 12.months
end
