# Custom in-place editing
module InPlaceEditorHelper
  def in_place_editor_field(record_symbol, attribute_symbol, record, script = false, truncate_to = nil, value = nil, enter_edit_mode = false)
    render :partial => "shared/inline", :locals => { :record_symbol => record_symbol, :attribute_symbol => attribute_symbol, 
                                                     :record => record, :script => script, :truncate_to => truncate_to, :value => value, :enter_edit_mode => enter_edit_mode }
  end
end
