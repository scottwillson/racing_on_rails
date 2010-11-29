module ApplicationHelper
  # Wrap +text+ in div tags, unless +text+ is blank
  def div(text)
    "<div>#{text}</div>" unless text.blank?
  end
  
  # RacingAssociation.current.short_name: page title
  def page_title
    return "#{RacingAssociation.current.short_name}: #{@page_title}" if @page_title
    
    if @page && !@page.title.blank?
      return "#{RacingAssociation.current.short_name}: #{@page.title}"
    end
    
    "#{RacingAssociation.current.short_name}: #{controller.controller_name.titleize}: #{controller.action_name.titleize}"
  end
  
  # Defaults to text length of 20
  def truncate_from_end(text)
    return text if text.blank? || text.size <= 20
    
    "...#{text[-20, 20]}"
  end
  
  # Add to_excel to strip out CSV-invalid characters
  def to_excel(value)
    if value.present? && value.respond_to?(:gsub)
      value.gsub(/[\t\n\r]/, " ")
    else
      value
    end
  end

  # Only need this helper once, it will provide an interface to convert a block into a partial.
  # 1. Capture is a Rails helper which will 'capture' the output of a block into a variable
  # 2. Merge the 'body' variable into our options hash
  # 3. Render the partial with the given options hash. Just like calling the partial directly.
  def block_to_partial(partial_name, options = {}, &block)
    options.merge!(:body => capture(&block))
    concat(render(:partial => partial_name, :locals => options))
  end
end
