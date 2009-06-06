module Admin::ArticleCategoriesHelper
  def display_categories(categories, parent_id)
    ret = "<ul>" 
      for category in categories
        if category.parent_id == nil
      	  category.parent_id = 0
        elsif category.parent_id == parent_id
          ret << display_category(category)
        end
      end
    ret << "</ul>" 
  end

  def display_category(category)
    ret = "<li>"
    ret << link_to(h(category.name), :action => "edit", :id => category)
    ret << " - " << h(category.description)
    ret << display_categories(category.children, category.id) if category.children.any?
    ret << "</li>" 
  end

  def tree_select(categories, model, name, selected=0, allow_root = true, level = 0, init = true)
    html = ""
    if init
      html << "<select name=\"#{model}[#{name}]\" id=\"#{model}_#{name}\">\n"
      if allow_root
        # The "Root" option is added
        # so the user can choose a parent_id of 0
        html << "\t<option value=\"0\""
        html << " selected=\"selected\"" if selected.parent_id == 0
        html << ">Root</option>\n"
      end
    end

    if categories.length > 0
      level += 1 # keep position
      categories.collect do |cat|
        html << "\t<option value=\"#{cat.id}\" style=\"padding-left:#{level * 10}px\""
        # alptodo: we need to be able to tell this routine what field to look at to determine parent ID
        # with articles it is article_category_id
        # with article_categories it is parent_id
        if model == "article"
          html << ' selected="selected"' if cat.id == selected.article_category_id
        else  
          html << ' selected="selected"' if cat.id == selected.parent_id
        end
        html << ">#{cat.name}</option>\n"
        html << tree_select(cat.children, model, name, selected, allow_root, level, false)
      end
    end
    html << "</select>\n" if init
    return html
  end
end
