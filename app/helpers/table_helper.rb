module TableHelper
  def table(collection_symbol, &block)
    render(:partial => "table/base", :locals => { :collection => assigns[collection_symbol.to_s] })
  end
end