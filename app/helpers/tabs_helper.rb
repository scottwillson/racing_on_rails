module TabsHelper
  def tabs(select_current_page = true)
    tabs = Tabs.new(@controller)
    yield tabs
    tabs.to_html(select_current_page)
  end

  class Tabs
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::UrlHelper

    def initialize(controller)
      @controller = controller
      @tabs = []
    end

    def add(name, options = {}, html_options = {}, &block)
      _html_options = {:onmouseover => "hover(this)", :onmouseout => "hoverOut(this)"}
      _html_options.merge(html_options) if html_options
      @tabs << [name, options, _html_options]
    end

    def select(name)
      @selected_name = name
    end

    # Builder escapes text, which is not what we want
    def to_html(select_current_page = true)
      table_class = "tabs"
      table_class = "tabs_solo" if @tabs.size < 2
      html = <<HTML
  <div class="centered">
    <table class="#{table_class}">
      <tr>
HTML
      @tabs.each_with_index do |tab, index|
        if index == 0
          if select_current_page && current_page?(tab[1])
            html << "      <td class=\"first_selected\"><div class=\"first_selected\"><span>"
          else
            html << "      <td class=\"first\"><div class=\"first\"><span>"
          end
          if select_current_page
            html << link_to_unless_current(tab.first, tab[1], tab[2]).to_s
          else
            html << link_to(tab.first, tab[1], tab[2]).to_s
          end
          html << "</span></div>"
          if @tabs.size < 2
            if select_current_page && current_page?(tab[1])
              html << "</td>\n      <td class=\"last_selected\"><div class=\"last_selected\">"
              html << "<span>&nbsp;</span></div>"
            else
              html << "</td>\n      <td class=\"last\"><div class=\"last\"><span>&nbsp;</span></div>"
            end
          end
        elsif index == @tabs.size - 1
          if select_current_page && current_page?(tab[1])
            html << "      <td class=\"last_selected\"><div class=\"last_selected\"><span>"
          else
            html << "      <td class=\"last\"><div class=\"last\"><span>"
          end
          if select_current_page
            html << link_to_unless_current(tab.first, tab[1], tab[2]).to_s
          else
            html << link_to(tab.first, tab[1], tab[2]).to_s
          end
          html << "</span></div>"
        else
          if select_current_page && current_page?(tab[1])
            html << "      <td class=\"selected\"><div class=\"selected\"><span>"
          else
            html << "      <td><div><span>"
          end
          if select_current_page
            html << link_to_unless_current(tab.first, tab[1], tab[2]).to_s
          else
            html << link_to(tab.first, tab[1], tab[2]).to_s
          end
          html << "</span></div>"
        end
        html << "</td>\n"
      end
      end_html = <<HTML
      </tr>
    </table>
  </div>
HTML
      html << end_html
    end
  end
end