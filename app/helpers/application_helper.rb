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
    if value.try :respond_to?, :gsub
      value.gsub(/[\t\n\r]/, " ")
    else
      value
    end
  end
  
  # FIXME Move to helper
  # FIXME use parse args replacement
  def editable(object, attribute, options = {})
    object_name = ActiveModel::Naming.singular(object)
    
    if options.present? && options[:length].present?
      value = truncate(object.send(attribute), :length => options[:length])
    else
      value = object.send(attribute)
    end
    
    if options.present? && options[:as].present?
      _object_name = options[:as].to_s
    else
      _object_name = object_name
    end
    
    content_tag( 
      :div, 
      :class => "editable", 
      :id => "#{_object_name}_#{object.to_param}_#{attribute}",
      "data-id" => object.id, 
      "data-url" => url_for(:controller => _object_name.pluralize, :action => "update_attribute", :id => object.to_param), 
      "data-model" => _object_name, 
      "data-attribute" => attribute,
      "data-original" => value) do
        value
    end
  end

  # Only need this helper once, it will provide an interface to convert a block into a partial.
  # 1. Capture is a Rails helper which will 'capture' the output of a block into a variable
  # 2. Merge the 'body' variable into our options hash
  # 3. Render the partial with the given options hash. Just like calling the partial directly.
  def block_to_partial(partial_name, options = {}, &block)
    options.merge!(:body => capture(&block))
    render(:partial => partial_name, :locals => options)
  end
end
