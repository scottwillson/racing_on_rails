module OregonCupHelper

  def flyer_link_from_app_server(event)
    url = event.flyer
    unless url['http://']
      url.gsub!('../../', 'http://www.obra.org/')
    end
    "<a href=\"#{url}\">#{event.name}</a>"
  end

end
