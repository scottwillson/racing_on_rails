module OregonCupHelper

  # Link to old static OBRA website if not a full URL
  def flyer_link_from_app_server(event)
    url = event.flyer
    unless url['http://']
      url.gsub!('../../', "http://#{STATIC_HOST}/")
    end
    "<a href=\"#{url}\">#{event.name}</a>"
  end

end
