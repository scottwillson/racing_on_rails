module RacingOnRails
  class FormBuilder < ActionView::Helpers::FormBuilder
    def labelled_text_field(method, text = method.to_s.titleize, text_field_options = {})
      label_options = text_field_options.delete(:label) || {}
      %Q{#{label(method, "#{text}", label_options)} #{text_field(method, text_field_options)}}
    end

    def labelled_check_box(method, text = nil)
      label(method, "#{check_box(method)} #{text || method.to_s.titleize}", :class => "check_box")
    end
    
    def labelled_text_area(method, options = {})
      %Q{#{label(method, "#{method.to_s.titleize}", :class => 'text_area')}#{text_area(method, options)}}
    end
    
    # TODO get attribute from record
    def labelled_text(method, text, label_text = nil, label_options = {})
      %Q{#{label(method, "#{label_text || method.to_s.titleize}", label_options)} <div class="labelled" id="#{object_name}_#{method}">#{text}</div>}
    end
  end
end