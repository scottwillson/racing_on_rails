# frozen_string_literal: true

# Build navigational tabs as HTML table
module TabsHelper
  def tabs(active_text = nil, show_one: false)
    window = (3 if mobile_request?)

    tabs = Tabs.new(active_text, window, show_one: show_one)
    yield tabs
    render "tabs/tabs", tabs: tabs
  end

  class Tabs
    attr_reader :active_text, :show_one, :tabs, :window

    def initialize(active_text, window, show_one: false)
      @active_text = active_text.to_s
      @show_one = show_one
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
          if index == 0 || index.nil?
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

    def show_one?
      @show_one
    end
  end

  class Tab
    attr_reader :text, :path

    def initialize(text, path, active_text)
      @text = text.to_s
      @path = path

      @active = true if text && active_text && (text == active_text)
    end

    def active?
      @active == true
    end
  end
end
