module TableHelper
  def table(collection_symbol, caption = nil, &block)
    table = Table.new(collection_symbol, assigns[collection_symbol.to_s], caption, params[:sort_by] || "", params[:sort_direction])
    yield(table) if block
    table.sort!
    render(:partial => "table/base", :locals => { :table => table })
  end  
  
  class Table
    attr_reader :caption, :columns, :collection, :collection_symbol, :record_symbol, :sort_by, :sort_direction
    
    def initialize(collection_symbol, collection = [], caption = collection_symbol.to_s.titleize, sort_by = "", sort_direction = "")
      @caption = caption
      @collection = collection
      @collection_symbol = collection_symbol
      @record_symbol = collection_symbol.to_s.singularize.to_sym
      @sort_by = sort_by
      @sort_direction = sort_direction
    end
    
    def column(attribute, *options)
      columns(false) << TableHelper::Column.new(self, attribute, options.extract_options!)
    end
    
    def columns(default_if_empty = true)
      if default_if_empty
        @columns ||= [Column.new(self, :name, {})]
      else
        @columns ||= []
      end
    end
    
    def sort!
      return if sort_by.blank?
      
      sort_by.split(",").each do |sort_attribute|
        @collection = collection.sort_by(&sort_attribute.to_sym)
      end
        
      @collection.reverse! if sort_direction == "desc"
    end
  end

  class Column
    attr_reader :attribute, :editable, :format, :link, :sort_by, :style_class, :table, :title

    def initialize(table, attribute, *options)
      options = options.extract_options!
      @attribute = attribute
      @editable = options[:editable] || false
      @format = options[:format]
      @link = options[:link] || false
      @sort_by = [options[:sort_by] || attribute]
      sort_by.flatten!
      @style_class = options[:style_class] || attribute.to_s
      @table = table
      @title = options[:title] || @attribute.to_s.titlecase
    end
    
    def editable?
      @editable
    end
    
    def link?
      @link
    end
    
    def sort_direction
      if table.sort_by == sort_by.join(",") && table.sort_direction == "asc"
        "desc"
      else
        "asc"
      end
    end
  end
end