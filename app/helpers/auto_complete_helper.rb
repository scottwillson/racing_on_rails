# Call our custom autocomplete partial
module AutoCompleteHelper
  def auto_complete(form_builder, model, attribute, path, label_text = nil)
    value = self.instance_variable_get("@#{model}").send("#{attribute}_name")
    render "auto_complete/base", 
             :f => form_builder, :model => model, :attribute => attribute, :path => path, :value => value, :label_text => label_text
  end
end
