# frozen_string_literal: true

module PageHelper
  # Look for a matching Page, but if none, fall back on Rails' template rendering
  def render_page(path, options = {})
    page = find_page(path)
    if page
      render({ inline: page.body }.merge(options))
    else
      render path, options
    end
  end

  def updated(page)
    "<span title=\"Created on #{page.created_at}\">#{time_ago_in_words(page.updated_at, include_seconds: true)} ago</span>".html_safe
  end

  def confirm_destroy_message(page)
    msg = "Really delete"
    msg = if page.title.blank?
            "#{msg} page?"
          else
            "#{msg} #{page.title}?"
          end

    msg = "#{msg} And delete all of its children?" if page.children.any?

    msg
  end

  private

  def find_page(path)
    Thread.current[:pages] = Hash.new { |hash, key| hash[key] = Page.find_by(path: key) } if Thread.current[:pages].nil?

    Thread.current[:pages][path]
  end
end
