# frozen_string_literal: true

module RacingOnRails
  # Label + form fields HTML
  module FormTagHelper
    extend ActionView::Helpers::FormTagHelper

    def labelled_text_field_tag(attribute, text = attribute.to_s.titleize, value = nil, text_field_options = {})
      label_options = text_field_options.delete(:label) || { class: "control-label" }

      help_block = nil
      help_block = "<span class='help-block'>#{text_field_options.delete(:help)}</span>" if text_field_options[:help]

      %(<div class="form-group">#{label_tag(attribute, (text || method.to_s.titleize).to_s, label_options)} #{text_field_tag(attribute, value, text_field_options)}#{help_block}</div></div>).html_safe
    end

    def labelled_text(object_name, method, label_text = nil, text = nil, label_options = {}, _text_class = nil)
      label_options[:class] = "col-sm-4 control-label"
      %(<div class="form-group #{method}">#{label(object_name, method, (label_text || method.to_s.titleize).to_s, label_options)} <div class="col-sm-8"><p class="form-control-static" id="#{object_name}_#{method}">#{text || instance_variable_get("@#{object_name}").send(method)}</p></div></div>).html_safe
    end
  end
end
