# frozen_string_literal: true

module WhitespaceHelper
  def show_whitespace(text)
    return text unless text

    preceding_whitespace(text) + text.strip + trailing_whitespace(text)
  end

  def preceding_whitespace(text)
    "·" * (text[/\A\s+/] || "").size
  end

  def trailing_whitespace(text)
    "·" * (text[/\s+\z/] || "").size
  end
end
