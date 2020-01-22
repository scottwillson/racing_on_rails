# frozen_string_literal: true

require "countries"

module RacingOnRails
  # Label + form fields HTML. Wrap checkboxes in divs (probably should do this for all label + field chunks).
  class FormBuilder < ActionView::Helpers::FormBuilder
    # Set +editable+ to false for read-only
    def labelled_text_field(method, text = method.to_s.titleize, text_field_options = { class: "form-control" })
      label_options = text_field_options.delete(:label) || { class: "control-label col-sm-4" }
      editable = text_field_options.delete(:editable)
      if editable == false
        %(#{label(method, (text || method.to_s.titleize).to_s, label_options)} <div id="#{object_name}_#{method}">#{@object.send(method)}</div>).html_safe
      else
        help_block = nil
        help_block = "<span class='help-block'>#{text_field_options.delete(:help)}</span>" if text_field_options[:help]
        %(<div class="form-group #{method}">#{label(method, (text || method.to_s.titleize).to_s, label_options)} <div class="col-sm-8">#{text_field(method, text_field_options)}#{help_block}</div></div>).html_safe
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
        %(#{label(method, (text || method.to_s.titleize).to_s, label_options)} <div id="#{object_name}_#{method}">#{@object.send(method)}</div>).html_safe
      else
        help_block = nil
        help_block = "<span class='help-block'>#{options.delete(:help)}</span>" if options[:help]
        %(<div class="form-group">#{label(method, (text || method.to_s.titleize).to_s, label_options)}<div class="col-sm-8">#{select(method, choices, options, html_options)}#{help_block}</div></div>).html_safe
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

    def labelled_password_field(method, text = method.to_s.titleize, password_field_options = { class: "form-control" })
      label_options = password_field_options.delete(:label) || { class: "control-label col-sm-4" }
      help_block = nil
      help_block = "<span class='help-block'>#{password_field_options.delete(:help)}</span>" if password_field_options[:help]
      %(<div class="form-group #{method}">#{label(method, (text || method.to_s.titleize).to_s, label_options)} <div class="col-sm-8">#{password_field(method, password_field_options)}#{help_block}</div></div>).html_safe
    end

    # Set +editable+ to false for read-only
    def labelled_check_box(method, text = nil, check_box_options = {})
      label_options = check_box_options.delete(:label) || {}
      if check_box_options[:editable] == false
        labelled_text method, @object.send(method) ? "Yes" : "No", text, check_box_options
      else
        %(<div class="form-group"><div class="col-sm-offset-4 col-sm-8"><div class="checkbox">#{label(method, label_options) { "#{check_box(method, check_box_options)}#{text || method.to_s.titleize}".html_safe }}</div></div></div>).html_safe
      end
    end

    def labelled_radio_button(method, text = nil, options = {})
      label_options = options.delete(:label) || {}
      %(<div class="form-group"><div class="col-sm-offset-4 col-sm-8"><div class="radio">#{label(method, label_options) { "#{radio_button(method, options)}#{text || method.to_s.titleize}".html_safe }}</div></div></div>).html_safe
    end

    # Set +editable+ to false for read-only
    def labelled_text_area(method, options = { class: "form-control", rows: 6 })
      label_options = options.delete(:label) || { class: "col-sm-12" }
      text = label_options[:text] if label_options

      help_block = nil
      help_block = "<span class='help-block'>#{options.delete(:help)}</span>" if options[:help]

      if options[:editable] == false
        %(<div class="form-group">#{label(method, "#{text || method.to_s.titleize},", label_options)} <div id="#{object_name}_#{method}">#{@object.send(method)}</div></div>).html_safe
      else
        %(<div class="form-group">#{label(method, (text || method.to_s.titleize).to_s, label_options)}<div class="col-sm-12">#{text_area(method, options)}#{help_block}</div></div>).html_safe
      end
    end

    def labelled_text(method, text = nil, label_text = nil, label_options = {})
      label_options[:class] = "col-sm-4 control-label"
      %(<div class="form-group #{method}">#{label(method, (label_text || method.to_s.titleize).to_s, label_options)} <div class="col-sm-8"><p class="form-control-static" id="#{object_name}_#{method}">#{text || @object.send(method)}</p></div></div>).html_safe
    end

    def labelled_select_modal(method, type, remove_button = true)
      %(<div class="form-group">#{label(method, method.to_s.titleize.to_s, class: "control-label col-sm-4")}<div class="col-sm-8">#{select_modal(method, type, remove_button)}</div></div>).html_safe
    end

    def select_modal(method, type, remove_button = true)
      # Private ActionView methods
      sanitized_method_name = method.to_s.sub(/\?$/, "").to_sym
      sanitized_object_name = object_name.to_s.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "").to_sym
      @template.render(
        "modals/button",
        f: self,
        method: sanitized_method_name,
        object_name: sanitized_object_name,
        object: @object,
        remove_button: remove_button,
        target: "#{sanitized_object_name}_#{sanitized_method_name}",
        type: type
      )
    end
  end
end
