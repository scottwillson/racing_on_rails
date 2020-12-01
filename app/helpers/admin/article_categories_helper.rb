# frozen_string_literal: true

# HTML chunks for ArticleCategories UL tree
module Admin::ArticleCategoriesHelper
  def display_categories(categories, parent_id)
    ret = +"<ul>"
    categories.each do |category|
      if category.parent_id.nil?
        category.parent_id = 0
      elsif category.parent_id == parent_id
        ret << display_category(category)
      end
    end
    ret << "</ul>"
    ret.html_safe
  end

  def display_category(category)
    ret = +"<li>"
    ret << link_to(h(category.name), action: "edit", id: category)
    ret << " - " << h(category.description)
    ret << display_categories(category.children, category.id) if category.children.any?
    ret << "</li>"
    ret.html_safe
  end

  def tree_select(categories, model, name, selected = 0, allow_root = true, level = 0, init = true)
    html = +""
    if init
      html << "<select class=\"form-control\" name=\"#{model}[#{name}]\" id=\"#{model}_#{name}\">\n"
      if allow_root
        # The "Root" option is added
        # so the user can choose a parent_id of 0
        html << "\t<option value=\"0\""
        html << " selected=\"selected\"" if selected.parent_id == 0
        html << ">Root</option>\n"
      end
    end

    unless categories.empty?
      level += 1 # keep position
      categories.collect do |cat|
        html << "\t<option value=\"#{cat.id}\" style=\"padding-left:#{level * 10}px\""
        # TODO: we need to be able to tell this routine what field to look at to determine parent ID
        # with articles it is article_category_id
        # with article_categories it is parent_id
        if model == "article"
          html << ' selected="selected"' if cat.id == selected.article_category_id
        elsif cat.id == selected.parent_id
          html << ' selected="selected"'
        end
        html << ">#{cat.name}</option>\n"
        html << tree_select(cat.children, model, name, selected, allow_root, level, false)
      end
    end
    html << "</select>\n" if init
    html.html_safe
  end
end
