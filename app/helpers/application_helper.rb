# frozen_string_literal: true

module ApplicationHelper
  # Wrap +text+ in div tags, unless +text+ is blank
  def div(text)
    "<div>#{text}</div>" if text.present?
  end

  # RacingAssociation.current.short_name: page title
  def page_title
    return "#{RacingAssociation.current.short_name}: #{@page_title}" if @page_title

    return "#{RacingAssociation.current.short_name}: #{@page.title}" if @page&.title.present?

    "#{RacingAssociation.current.short_name}: #{controller.controller_name.titleize}: #{controller.action_name.titleize}"
  end

  # Defaults to text length of 20
  def truncate_from_end(text)
    return text if text.blank? || text.size <= 20

    "...#{text[-20, 20]}"
  end

  # Add to_excel to strip out CSV-invalid characters.
  # Mark all content as "safe." It won't be parsed in a browser, but Erb will escape apostrophes.
  def to_excel(value)
    case value
    when TrueClass
      "1"
    when FalseClass
      "0"
    when Integer
      value
    when NilClass
      ""
    when Date, Time, DateTime
      value.to_s(:mdY)
    else
      _value = value.dup
      _value = _value[0, 250] if _value.mb_chars.length > 250

      if _value.try(:respond_to?, :gsub)
        _value.gsub!(/[\t\n\r]/, " ")

        if _value[","]
          _value.gsub!('"', '\"')
          _value = "\"#{_value}\""
        end
      end

      return _value.html_safe if _value.try(:respond_to?, :html_safe)

      _value
    end
  end

  def markdown(source)
    renderer = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, space_after_headers: true)
    renderer.render(source).html_safe
  end

  def flash_js(key, message)
    "jQuery('.flash_messages').html('#{escape_javascript(render('layouts/flash_message', message: message, alert_class: alert_class(key)))}');".html_safe
  end

  def alert_class(key)
    if key == "warn"
      "alert-warning"
    else
      "alert-info"
    end
  end

  # Always use the Twitter Bootstrap pagination renderer
  def will_paginate(collection_or_options = nil, options = {})
    if collection_or_options.is_a? Hash
      options = collection_or_options
      collection_or_options = nil
    end
    options = options.merge(renderer: BootstrapPagination::Rails)
    tag.div(class: "pagination") { super(*[collection_or_options, options].compact) }
  end

  # Only need this helper once, it will provide an interface to convert a block into a partial.
  # 1. Capture is a Rails helper which will 'capture' the output of a block into a variable
  # 2. Merge the 'body' variable into our options hash
  # 3. Render the partial with the given options hash. Just like calling the partial directly.
  def block_to_partial(partial_name, options = {}, &block)
    options[:body] = capture(&block)
    render partial_name, options
  end

  def cache_key(*keys)
    if keys.present?
      cache_key_prefix + keys
    else
      cache_key_prefix
    end
  end

  def cache_key_prefix
    [RacingAssociation.current.short_name, RacingAssociation.current.updated_at.try(:to_s, :number)]
  end
end
