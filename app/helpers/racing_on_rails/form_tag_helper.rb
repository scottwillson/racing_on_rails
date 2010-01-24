module RacingOnRails
  module FormTagHelper
    extend ActionView::Helpers::FormTagHelper
    
    def labelled_text_field_tag(attribute, text = attribute.to_s.titleize, value = nil, text_field_options = {})
      label_options = text_field_options.delete(:label) || {}
      %Q{#{label_tag(attribute, "#{text}", label_options)} #{text_field_tag(attribute, value, text_field_options)}}
    end
    
    def labelled_text(object_name, method, label_text = nil, text = nil, label_options = {}, text_class = nil)
      %Q{#{label(object_name, method, "#{label_text || method.to_s.titleize}", label_options)} <div class="labelled #{text_class}" id="#{object_name}_#{method}">#{text || instance_variable_get("@#{object_name}").send(method)}</div>}
    end
  end
end