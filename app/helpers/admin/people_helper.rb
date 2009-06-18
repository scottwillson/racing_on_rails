module Admin::PeopleHelper
  def ppl_escape(text)
    text.gsub(',', '\""') if text
  end
end
