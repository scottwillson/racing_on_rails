module RacingOnRails
  # Label + form fields HTML
  module FormTagHelper
    extend ActionView::Helpers::FormTagHelper

    def labelled_text_field_tag(attribute, text = attribute.to_s.titleize, value = nil, text_field_options = {})
      label_options = text_field_options.delete(:label) || { :class => "control-label" }

      help_block = nil
      if text_field_options[:help]
        help_block = "<span class='help-block'>#{text_field_options.delete(:help)}</span>"
      end

      %Q{<div class="form-group">#{label_tag(attribute, "#{text || method.to_s.titleize}", label_options)} #{text_field_tag(attribute, value, text_field_options)}#{help_block}</div></div>}.html_safe
    end

    def labelled_text(object_name, method, label_text = nil, text = nil, label_options = {}, text_class = nil)
      label_options.merge!(:class => "col-sm-4 control-label")
      %Q{<div class="form-group #{method.to_s}">#{label(object_name, method, "#{label_text || method.to_s.titleize}", label_options)} <div class="col-sm-8"><p class="form-control-static" id="#{object_name}_#{method}">#{text || instance_variable_get("@#{object_name}").send(method)}</p></div></div>}.html_safe
    end
  end
end
