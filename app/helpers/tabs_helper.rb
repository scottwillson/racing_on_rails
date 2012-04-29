# Build navigational tabs as HTML table
module TabsHelper
  def tabs(select_current_page = true)
    tabs = Tabs.new(controller)
    yield tabs
    tabs.to_html(select_current_page).html_safe
  end

  class Tabs
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::UrlHelper
    
    attr_accessor :controller

    def initialize(controller)
      self.controller = controller
      @tabs = []
    end

    def add(name, options = {}, html_options = {}, &block)
      _html_options = {}
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
      table_class = "tabs solo" if @tabs.size < 2
      html = <<HTML
    <ul class="#{table_class}">
HTML
      @tabs.each_with_index do |tab, index|
        if index == 0
          if select_current_page && current_page?(tab.options)
            html << "      <li class=\"first_selected\">"
          else
            html << "      <li class=\"first\">"
          end
          if select_current_page
            html << link_to_unless_current(tab.name, tab.options, tab.html_options).to_s
          else
            html << link_to(tab.name, tab.options, tab.html_options).to_s
          end
          if @tabs.size < 2
            if select_current_page && current_page?(tab.options)
              html << "\n      <li class=\"last_selected\">"
              html << "&nbsp;"
            else
              html << "\n      <li class=\"last\">&nbsp;"
            end
          end
        elsif index == @tabs.size - 1
          if select_current_page && current_page?(tab.options)
            html << "      <li class=\"last_selected\">"
          else
            html << "      <li class=\"last\">"
          end
          if select_current_page
            html << link_to_unless_current(tab.name, tab.options, tab.html_options).to_s
          else
            html << link_to(tab.name, tab.options, tab.html_options).to_s
          end
        else
          if select_current_page && current_page?(tab.options)
            html << "      <li class=\"selected\">"
          else
            html << "      <li>"
          end
          if select_current_page
            html << link_to_unless_current(tab.name, tab.options, tab.html_options).to_s
          else
            html << link_to(tab.name, tab.options, tab.html_options).to_s
          end
        end
        html << "</li>\n"
      end
      end_html = <<HTML
    </ul>
HTML
      html << end_html
    end
    
    # FIXME
    def _routes
      self.controller._routes
    end
    
    def request
      self.controller.request
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
