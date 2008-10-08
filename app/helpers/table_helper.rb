module TableHelper
  def table(collection_symbol = controller.controller_name.to_sym, options = {}, &block)
    table = Table.new(collection_symbol, options[:collection] || assigns[collection_symbol.to_s], options)
    yield(table) if block
    table.sort!
    render(:partial => "table/base", :locals => { :table => table })
  end  
  
  class Table
    attr_reader :caption, :columns, :collection, :collection_symbol, :embedded, :record_symbol, :sort_by, :sort_direction
    
    def initialize(collection_symbol, collection = [], options = {})
      @caption = options[:caption] || collection_symbol.to_s.titleize
      @collection = collection
      @collection_symbol = collection_symbol
      @embedded = options[:embedded] || false
      @record_symbol = collection_symbol.to_s.singularize.to_sym
      @sort_by = options[:sort_by] || ""
      @sort_by = sort_by.to_s
      @sort_direction = options[:sort_direction] || ""
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
    
    def embedded?
      @embedded
    end
    
    def sort!
      return if sort_by.blank?
      
      sort_by.split(",").each do |sort_attribute|
        sort_attribute_symbol = sort_attribute.to_sym
        collection.sort! { |x, y| (x.send(sort_attribute_symbol) || "") <=> (y.send(sort_attribute_symbol) || "") }
      end
        
      collection.reverse! if sort_direction == "desc"
    end
  end

  class Column
    attr_reader :attribute, :editable, :format, :link_to, :sort_by, :style_class, :table, :title

    def initialize(table, attribute, *options)
      options = options.extract_options!
      @attribute = attribute
      @editable = options[:editable] || false
      @format = options[:format]
      if options.include?(:link_to)
        @link_to = options[:link_to]
      elsif attribute == :name
        @link_to = :show
      end
      @sort_by = [options[:sort_by] || attribute]
      sort_by.flatten!
      @style_class = options[:style_class] || attribute.to_s
      @table = table
      @title = options[:title] || @attribute.to_s.titlecase
    end
    
    def editable?
      @editable
    end
    
    def link_to_edit?
      link_to == :edit
    end
    
    def link_to_show?
      link_to == :show
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