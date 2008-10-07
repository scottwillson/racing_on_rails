module TableHelper
  def table(collection_symbol, caption = nil, &block)
    table = Table.new(collection_symbol, assigns[collection_symbol.to_s], caption, params[:order] || "")
    yield(table) if block
    render(:partial => "table/base", :locals => { :table => table })
  end  
  
  class Table
    attr_reader :caption, :columns, :collection, :collection_symbol, :order, :record_symbol
    
    def initialize(collection_symbol, collection = [], caption = collection_symbol.to_s.titleize, order_param = "")
      @caption = caption
      @collection = collection
      @collection_symbol = collection_symbol
      @order = order_param.split(",").collect do |param|
        [param.split.first, param.split.last]
      end
      @record_symbol = collection_symbol.to_s.singularize.to_sym
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
  end

  class Column
    attr_reader :attribute, :editable, :format, :link, :order, :style_class, :table, :title

    def initialize(table, attribute, *options)
      options = options.extract_options!
      @attribute = attribute
      @editable = options[:editable] || false
      @format = options[:format]
      @link = options[:link] || false
      @order = [options[:order] || attribute]
      @order.flatten!
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
    
    def order_param
      if !table.order.empty? && table.order.first.first == order.first.to_s && table.order.first.last == "asc"
        direction = "desc"
      else
        direction = "asc"
      end
      order.inject([]) { |param, order_attribute| param << "#{order_attribute} #{direction}" }.join(", ")
    end
  end
end