# frozen_string_literal: true

# Build navigational tabs as HTML table
module TabsHelper
  def tabs(active_text = nil, show_one: false)
    tabs = Tabs.new(active_text, show_one: show_one)
    yield tabs
    render "tabs/tabs", tabs_array: tabs
  end

  class Tabs
    include Enumerable

    attr_reader :active_text, :show_one, :tabs

    def initialize(active_text, show_one: false)
      @active_text = active_text.to_s
      @show_one = show_one
      @tabs = []
    end

    def active
      @active ||= tabs.detect(&:active?)
    end

    def add(text, path)
      tabs << Tab.new(text.to_s, path, active_text)
    end

    def each(&block)
      tabs.each(&block)
    end

    def inactives
      tabs.reject(&:active?)
    end

    def rest
      return [] if size < 2

      tabs[1, size - 1]
    end

    def show_one?
      @show_one
    end

    def size
      @size ||= to_a.size
    end
  end

  class Tab
    attr_reader :path, :text

    def initialize(text, path, active_text)
      @text = text.to_s
      @path = path

      @active = true if text && active_text && (text == active_text)
    end

    def active?
      @active == true
    end

    def css_class(dropdown = false)
      if active? && dropdown
        %w(active dropdown)
      elsif active?
        %w(active)
      elsif dropdown
        %w(dropdown)
      else
        []
      end
    end
  end
end
