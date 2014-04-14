# Build navigational tabs as HTML table
module TabsHelper
  def tabs(active_text = nil)
    if mobile_request?
      window = 3
    else
      window = nil
    end

    tabs = Tabs.new(active_text, window)
    yield tabs
    render "tabs/tabs", tabs: tabs
  end

  class Tabs
    attr_reader :active_text, :tabs, :window

    def initialize(active_text, window)
      @active_text = active_text.to_s
      @tabs = []
      @window = window
    end

    def add(text, path)
      @tabs << Tab.new(text.to_s, path, active_text)
    end

    def each(&block)
      tabs.each(&block)
    end

    def tabs
      if window
        if @tabs.size <= window
          @tabs[0, window]
        else
          index = @tabs.index(&:active?)
          if index == 0 || index == nil
            @tabs[0, window]
          elsif (index + 1) == @tabs.size
            @tabs[-window, window]
          else
            @tabs[index - 1, window]
          end
        end
      else
        @tabs
      end
    end

    def many?
      @tabs.many?
    end
  end

  class Tab
    attr_reader :text, :path

    def initialize(text, path, active_text)
      @text = text.to_s
      @path = path

      if text && active_text && (text == active_text)
        @active = true
      end
    end

    def active?
      @active == true
    end
  end
end
