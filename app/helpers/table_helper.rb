module TableHelper
  def table(collection_symbol, caption = nil, &block)
    table = Table.new(caption)
    yield(table) if block
    record_symbol = collection_symbol.to_s.singularize.to_sym
    render(:partial => "table/base", :locals => { :collection => assigns[collection_symbol.to_s], :caption => table.caption, :columns => table.columns, :record_symbol => record_symbol })
  end
  
  class Table
    attr_reader :caption, :columns
    
    def initialize(caption = nil)
      @caption = caption
      @columns = []
    end
    
    def column(attribute, *options)
      columns << TableHelper::Column.new(attribute, options.extract_options!)
    end
  end

  class Column
    attr_reader :attribute, :editable, :format, :link, :style_class, :title

    def initialize(attribute, *options)
      options = options.extract_options!
      @attribute = attribute
      @editable = options[:editable] || false
      @format = options[:format]
      @link = options[:link] || false
      @style_class = options[:style_class] || attribute.to_s
      @title = options[:title] || @attribute.to_s.titlecase
    end
    
    def editable?
      @editable
    end
    
    def link?
      @link
    end
  end
end