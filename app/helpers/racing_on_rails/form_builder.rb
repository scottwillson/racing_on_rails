module RacingOnRails
  # Label + form fields HTML. Wrap checkboxes in divs (probably should do this for all label + field chunks).
  class FormBuilder < ActionView::Helpers::FormBuilder
    # Set +editable+ to false for read-only
    def labelled_text_field(method, text = method.to_s.titleize, text_field_options = { class: "form-control" } )
      label_options = text_field_options.delete(:label) || { class: "control-label col-sm-4" }
      editable = text_field_options.delete(:editable)
      if editable == false
        %Q{#{label(method, "#{text || method.to_s.titleize}", label_options)} <div id="#{object_name}_#{method}">#{@object.send(method)}</div>}.html_safe
      else
        help_block = nil
        if text_field_options[:help]
          help_block = "<span class='help-block'>#{text_field_options.delete(:help)}</span>"
        end
        %Q{<div class="form-group #{method.to_s}">#{label(method, "#{text || method.to_s.titleize}", label_options)} <div class="col-sm-8">#{text_field(method, text_field_options)}#{help_block}</div></div>}.html_safe
      end
    end

    def labelled_date_picker(method)
      @template.render "shared/date_picker", f: self, method: method, object: @object, object_name: object_name
    end

    def labelled_datetime_picker(method)
      @template.render "shared/date_time_picker", f: self, method: method, object: @object, object_name: object_name
    end

    # Set +editable+ to false for read-only
    def labelled_select(method, choices, options = {}, html_options = { class: "form-control" })
      label_options = options.delete(:label) || { class: "control-label col-sm-4" }
      text = label_options.delete(:text) if label_options
      if options[:editable] == false
        %Q{#{label(method, "#{text || method.to_s.titleize}", label_options)} <div id="#{object_name}_#{method}">#{@object.send(method)}</div>}.html_safe
      else
        help_block = nil
        if options[:help]
          help_block = "<span class='help-block'>#{options.delete(:help)}</span>"
        end
        %Q{<div class="form-group">#{label(method, "#{text || method.to_s.titleize}", label_options)}<div class="col-sm-8">#{select(method, choices, options, html_options)}#{help_block}</div></div>}.html_safe
      end
    end

    # List from Countries::COUNTRIES
    def labelled_country_select(method, options = {})
      labelled_select(
        method,
        RacingAssociation.current.priority_country_options + Countries::COUNTRIES,
        options.merge(label: { text: "Country", class: "control-label col-sm-4" }, class: "form-control")
      )
    end

    def labelled_password_field(method, text = method.to_s.titleize, password_field_options = { class: "form-control" } )
      label_options = password_field_options.delete(:label) || { class: "control-label col-sm-4" }
      help_block = nil
      if password_field_options[:help]
        help_block = "<span class='help-block'>#{password_field_options.delete(:help)}</span>"
      end
      %Q{<div class="form-group #{method.to_s}">#{label(method, "#{text || method.to_s.titleize}", label_options)} <div class="col-sm-8">#{password_field(method, password_field_options)}#{help_block}</div></div>}.html_safe
    end

    # Set +editable+ to false for read-only
    def labelled_check_box(method, text = nil, check_box_options = {})
      label_options = check_box_options.delete(:label) || {}
      if check_box_options[:editable] == false
        labelled_text method, @object.send(method) ? "Yes" : "No", text, check_box_options
      else
        %Q{<div class="form-group"><div class="col-sm-offset-4 col-sm-8"><div class="checkbox">#{label(method, label_options) { "#{check_box(method, check_box_options)}#{text || method.to_s.titleize}".html_safe }}</div></div></div>}.html_safe
      end
    end

    def labelled_radio_button(method, value, text = nil)
      %Q{<div class="radio">#{radio_button(method, value)}#{label(method, text || method.to_s.titleize)}</div>}.html_safe
    end

    # Set +editable+ to false for read-only
    def labelled_text_area(method, options = { class: "form-control", rows: 6 })
      label_options = options.delete(:label) || { class: "col-sm-12"}
      text = label_options[:text] if label_options

      help_block = nil
      if options[:help]
        help_block = "<span class='help-block'>#{options.delete(:help)}</span>"
      end

      if options[:editable] == false
        %Q{<div class="form-group">#{label(method, "#{text || method.to_s.titleize},", label_options)} <div id="#{object_name}_#{method}">#{@object.send(method)}</div></div>}.html_safe
      else
        %Q{<div class="form-group">#{label(method, "#{text || method.to_s.titleize}", label_options)}<div class="col-sm-12">#{text_area(method, options)}#{help_block}</div></div>}.html_safe
      end
    end

    def labelled_text(method, text = nil, label_text = nil, label_options = {})
      label_options.merge!(class: "col-sm-4 control-label")
      %Q{<div class="form-group #{method.to_s}">#{label(method, "#{label_text || method.to_s.titleize}", label_options)} <div class="col-sm-8"><p class="form-control-static" id="#{object_name}_#{method}">#{text || @object.send(method)}</p></div></div>}.html_safe
    end
  end
end
