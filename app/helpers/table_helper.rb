# Build HTML table with standard structure. Wrap caption div + table in div container for consistent captions across browsers.
# Show "None" if empty content. Add sortable headers.
# 
module TableHelper
  # == Arguments
  # * caption
  # * caption_visible. Default true
  # * id. CSS ID
  # * style_class or class. CSS style class
  # * collection. Table contents. Only used to show "None"
  # * columns. Default 1. If insert_header is true, insert +columns+ <th />
  # * insert_header. Insert <th/> for "bar" on top of tables
  def table(options = {}, &block)
    # TODO Use merge or something
    options[:caption] = nil unless options[:caption]
    options[:caption_visible] = true unless options[:caption_visible]
    options[:new_action] = nil unless options[:new_action]
    options[:id] = nil unless options[:id]
    options[:style_class] = options[:class]
    options.delete(:class)
    options[:collection] = options[:collection]
    options[:columns] = options[:columns] || 1
    options[:insert_header] = nil unless (options[:insert_header] && RacingAssociation.current.always_insert_table_headers?)
    block_to_partial "table/base", options, &block
  end

  # == Arguments
  # * sort_by: Sort by this attribute
  # * style_class or class. CSS
  # * title. <th>+title+</th>
  # * sort_params. Append to sort link
  # * sort_direction. "asc" or "desc"
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

    render :partial => "table/th", :locals => locals
  end
  
  # Sort rows in memory based on +sort_by+. Paginated table contents need to be sorted in DB.
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