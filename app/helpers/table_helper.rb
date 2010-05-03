module TableHelper
  def table(options = {}, &block)
    # TODO Use merge or something
    options[:caption] = nil unless options[:caption]
    options[:caption_visible] = true unless options[:caption_visible]
    options[:fix_table_column_widths] = true unless options.include?(:fix_table_column_widths)
    options[:new_action] = nil unless options[:new_action]
    options[:id] = nil unless options[:id]
    options[:style_class] = options[:class]
    options.delete(:class)
    options[:collection] = options[:collection]
    options[:columns] = options[:columns] || 1
    options[:insert_header] = nil unless (options[:insert_header] && ASSOCIATION.always_insert_table_headers?)
    block_to_partial("table/base", options, &block)
   end

  def th(attribute = nil, *options)
    _attribute = nil
    _attribute = attribute.to_s if attribute
    
    locals = { :attribute => _attribute }
    options = options.extract_options!
    locals[:sort_by] = [options[:sort_by] || _attribute].flatten
    locals[:style_class] = options[:class] || _attribute
    locals[:title] = options[:title] || (_attribute.titlecase  if _attribute)
    locals[:sort_params] = options[:sort_params] || {}
    
    if params[:sort_by] == _attribute && params[:sort_direction] == "asc"
      locals[:sort_direction] = "desc"
    else
      locals[:sort_direction] = "asc"
    end
    
    render(:partial => "table/th", :locals => locals)
  end
  
  def sort_rows(collection, sort_by, sort_direction)
    return collection if sort_by.blank?
    
     sort_by.split(",").each do |sort_attribute|
      sort_attribute_symbol = sort_attribute.to_sym
      collection.sort! { |x, y| (x.send(sort_attribute_symbol) || "") <=> (y.send(sort_attribute_symbol) || "") }
    end
      
    collection.reverse! if sort_direction == "desc"
    collection
  end
end