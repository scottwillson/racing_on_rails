# Build navigational tabs as HTML table
module TabsHelper
  def tabs(select_current_page = true)
    tabs = Tabs.new(@controller)
    yield tabs
    tabs.to_html select_current_page
  end

  class Tabs
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::UrlHelper

    def initialize(controller)
      @controller = controller
      @tabs = []
    end

    def add(name, options = {}, html_options = {}, &block)
      _html_options = { :onmouseover => "hover(this)", :onmouseout => "hoverOut(this)" }
      _html_options.merge!(html_options) if html_options
      @tabs << Tab.new(name, options, _html_options)
    end
    
    # Show tab named +name+ as selected
    def select(name)
      @selected_name = name
    end

    # Builder escapes text, which is not what we want
    def to_html(select_current_page = true)
      table_class = "tabs"
      table_class = "tabs_solo" if @tabs.size < 2
      html = <<HTML
    <table class="#{table_class} centered">
      <tr>
HTML
      @tabs.each_with_index do |tab, index|
        if index == 0
          if select_current_page && current_page?(tab.options)
            html << "      <td class=\"first_selected\"><div class=\"first_selected\"><span>"
          else
            html << "      <td class=\"first\"><div class=\"first\"><span>"
          end
          if select_current_page
            html << link_to_unless_current(tab.name, tab.options, tab.html_options).to_s
          else
            html << link_to(tab.name, tab.options, tab.html_options).to_s
          end
          html << "</span></div>"
          if @tabs.size < 2
            if select_current_page && current_page?(tab.options)
              html << "</td>\n      <td class=\"last_selected\"><div class=\"last_selected\">"
              html << "<span>&nbsp;</span></div>"
            else
              html << "</td>\n      <td class=\"last\"><div class=\"last\"><span>&nbsp;</span></div>"
            end
          end
        elsif index == @tabs.size - 1
          if select_current_page && current_page?(tab.options)
            html << "      <td class=\"last_selected\"><div class=\"last_selected\"><span>"
          else
            html << "      <td class=\"last\"><div class=\"last\"><span>"
          end
          if select_current_page
            html << link_to_unless_current(tab.name, tab.options, tab.html_options).to_s
          else
            html << link_to(tab.name, tab.options, tab.html_options).to_s
          end
          html << "</span></div>"
        else
          if select_current_page && current_page?(tab.options)
            html << "      <td class=\"selected\"><div class=\"selected\"><span>"
          else
            html << "      <td><div><span>"
          end
          if select_current_page
            html << link_to_unless_current(tab.name, tab.options, tab.html_options).to_s
          else
            html << link_to(tab.name, tab.options, tab.html_options).to_s
          end
          html << "</span></div>"
        end
        html << "</td>\n"
      end
      end_html = <<HTML
      </tr>
    </table>
HTML
      html << end_html
    end
  end
  
  class Tab
    attr_reader :name, :options, :html_options

    def initialize(name, options, html_options)
      @name = name
      @options = options
      @html_options = html_options
    end
  end
end