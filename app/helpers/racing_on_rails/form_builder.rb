module RacingOnRails
  class FormBuilder < ActionView::Helpers::FormBuilder
    def labelled_text_field(method, text = method.to_s.titleize, text_field_options = {})
      label_options = text_field_options.delete(:label) || {}
      %Q{#{label(method, "#{text}", label_options)} #{text_field(method, text_field_options)}}
    end

    def labelled_password_field(method, text = method.to_s.titleize, password_field_options = {})
      label_options = password_field_options.delete(:label) || {}
      %Q{#{label(method, "#{text}", label_options)} #{password_field(method, password_field_options)}}
    end

    def labelled_check_box(method, text = nil, check_box_options = {})
      %Q{<div class="check_box">#{check_box(method, check_box_options)}#{label(method, text || method.to_s.titleize)}</div>}
    end
    
    def labelled_radio_button(method, value, text = nil)
      %Q{<div class="radio">#{radio_button(method, value)}#{label(method, text || method.to_s.titleize)}</div>}
    end
    
    def labelled_text_area(method, options = {})
      %Q{#{label(method, "#{method.to_s.titleize}", :class => 'text_area')}#{text_area(method, options)}}
    end
    
    # TODO get attribute from record
    def labelled_text(method, text = nil, label_text = nil, label_options = {})
      %Q{#{label(method, "#{label_text || method.to_s.titleize}", label_options)} <div class="labelled" id="#{object_name}_#{method}">#{text || @object.send(method)}</div>}
    end
  end
end