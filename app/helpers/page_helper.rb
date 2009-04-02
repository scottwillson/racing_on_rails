module PageHelper
  def render_page(path, options = {})
    page = Page.find_by_path(path)
    if page
      render({ :inline => page.body }.merge(options))
    else
      render({ :partial => path }.merge(options))
    end
  end
  
  def updated(page)
    "<span title=\"Created on #{page.created_at}\">#{time_ago_in_words(page.updated_at, true)} ago</span> by #{page.author.name}"
  end
  
  def confirm_destory_message(page)
    msg = "Really delete"
    if page.title.blank?
      msg = "#{msg} page?"
    else
      msg = "#{msg} #{page.title}?"
    end
    
    if !page.children.empty?
      msg = "#{msg} And delete all of its children?"
    end
    
    msg
  end
end
