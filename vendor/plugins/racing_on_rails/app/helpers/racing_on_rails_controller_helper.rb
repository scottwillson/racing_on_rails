module RacingOnRailsControllerHelper
  def attribute(record, name)
    render(:partial => '/admin/attribute', :locals => {:record => record, :name => name})
  end
end