module EditableHelper
  def editable(object, attribute, options = {})
    object_name = ActiveModel::Naming.singular(object)
    
    if !options[:value].nil?
      value = options[:value]
    else
      value = object.send(attribute)
    end

    if options[:length].present?
      value = truncate(value, :length => options[:length])
    end

    if options[:as].present?
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
        value.to_s
    end
  end
end
