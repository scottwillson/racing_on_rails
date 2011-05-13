module PageHelper
  # Look for a matching Page, but if none, fall back on Rails' template rendering
  def render_page(path, options = {})
    page = Page.find_by_path(path)
    if page
      render({ :inline => page.body }.merge(options))
    else
      render({ :partial => path }.merge(options))
    end
  end
  
  def updated(page)
    "<span title=\"Created on #{page.created_at}\">#{time_ago_in_words(page.updated_at, true)} ago</span> by #{page.author.name}".html_safe
  end
  
  def confirm_destroy_message(page)
    msg = "Really delete"
    if page.title.blank?
      msg = "#{msg} page?"
    else
      msg = "#{msg} #{page.title}?"
    end
    
    if page.children.any?
      msg = "#{msg} And delete all of its children?"
    end
    
    msg
  end
end
