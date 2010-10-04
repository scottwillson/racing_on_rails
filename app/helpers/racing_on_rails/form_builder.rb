module RacingOnRails
  # Label + form fields HTML. Wrap checkboxes in divs (probably should do this for all label + field chunks).
  class FormBuilder < ActionView::Helpers::FormBuilder
    # Set +editable+ to false for read-only
    def labelled_text_field(method, text = method.to_s.titleize, text_field_options = {})
      label_options = text_field_options.delete(:label) || {}
      if text_field_options[:editable] == false
        %Q{#{label(method, "#{text || method.to_s.titleize}", label_options)} <div class="labelled" id="#{object_name}_#{method}">#{@object.send(method)}</div>}
      else
        %Q{#{label(method, "#{text || method.to_s.titleize}", label_options)} #{text_field(method, text_field_options)}}
      end
    end

    # Set +editable+ to false for read-only
    def labelled_select(method, select_options, options = {})
      label_options = options.delete(:label) || {}
      text = label_options.delete(:text) if label_options
      if options[:editable] == false
        %Q{#{label(method, "#{text || method.to_s.titleize}", label_options)} <div class="labelled" id="#{object_name}_#{method}">#{@object.send(method)}</div>}
      else
        %Q{#{label(method, "#{text || method.to_s.titleize}", label_options)} #{select(method, select_options, options)}}
      end
    end

    # List from Countries::COUNTRIES
    def labelled_country_select(method, options = {})
      labelled_select method, RacingAssociation.current.priority_country_options + Countries::COUNTRIES, options.merge(:label => { :text => "Country" })
    end
    
    def labelled_password_field(method, text = method.to_s.titleize, password_field_options = {})
      label_options = password_field_options.delete(:label) || {}
      %Q{#{label(method, "#{text}", label_options)} #{password_field(method, password_field_options)}}
    end

    # Set +editable+ to false for read-only
    def labelled_check_box(method, text = nil, check_box_options = {})
      label_options = check_box_options.delete(:label) || {}
      if check_box_options[:editable] == false
        %Q{#{label(method, "#{text || method.to_s.titleize}", label_options)} <div class="labelled" id="#{object_name}_#{method}">#{@object.send(method)}</div>}
      else
        %Q{<div class="check_box"><div class="input">#{check_box(method, check_box_options)}</div><div  class="label">#{label(method, text || method.to_s.titleize)}</div></div>}
      end
    end
    
    def labelled_radio_button(method, value, text = nil)
      %Q{<div class="radio">#{radio_button(method, value)}#{label(method, text || method.to_s.titleize)}</div>}
    end
    
    # Set +editable+ to false for read-only
    def labelled_text_area(method, options = {})
      label_options = options.delete(:label) || {}
      text = label_options[:text] if label_options
      if options[:editable] == false
        %Q{#{label(method, "#{text || method.to_s.titleize}", :class => 'text_area')} <div class="labelled" id="#{object_name}_#{method}">#{@object.send(method)}</div>}
      else
        %Q{#{label(method, "#{text || method.to_s.titleize}", :class => 'text_area')}#{text_area(method, options)}}
      end
    end
    
    def labelled_text(method, text = nil, label_text = nil, label_options = {})
      %Q{#{label(method, "#{label_text || method.to_s.titleize}", label_options)} <div class="labelled" id="#{object_name}_#{method}">#{text || @object.send(method)}</div>}
    end
  end
end