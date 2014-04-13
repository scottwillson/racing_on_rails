module HumanDate
  class Parser
    def initialize
      Chronic.time_class = Time.zone
    end

    def parse(text)
      return nil if text.nil?

      _text = text.strip
      return "" if _text.blank?

      _text = remove_weekdays(_text)
      _text = _text.gsub(/^(\d+{1,4})-(\d+{1,2})-(\d+{1,4})/, '\1/\2/\3')

      Chronic.parse _text
    end

    protected

    def remove_weekdays(text)
      _text = text
      (Date::DAYNAMES + Date::ABBR_DAYNAMES).each do |day|
        _text = _text.gsub(/^#{day},/, "")
      end
      _text
    end
  end
end
