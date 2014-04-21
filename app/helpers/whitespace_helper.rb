module WhitespaceHelper
  def show_whitespace(text)
    return text unless text

    preceding_whitespace = (text[/\A\s+/] || "").size
    trailing_whitespace = (text[/\s+\z/] || "").size
    "#{"·" * preceding_whitespace}#{text.strip}#{"·" * trailing_whitespace}"
  end
end
