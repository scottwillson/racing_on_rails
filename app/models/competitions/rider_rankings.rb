# WSBA rider rankings. Members get points for top-10 finishes in any event.
# No longer used. Class remains for archived results.
class RiderRankings < Competition
  def friendly_name
    'Rider Rankings'
  end
  
  def notes
    if year.to_i > 2011
      "The WSBA is using the default USA Cycling ranking system from 2012 onward. Please see http://www.usacycling.org/events/rr.php."
    else
      self[:notes]
    end
  end
end
