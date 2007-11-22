module Admin::RacersHelper
  def ppl_escape(text)
    text.gsub(',', '\""') if text
  end
end
