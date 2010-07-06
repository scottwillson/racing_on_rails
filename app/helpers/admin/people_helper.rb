module Admin::PeopleHelper
  # Escape for FinishLynx PPL files
  def ppl_escape(text)
    text.gsub(',', '\""') if text
  end
end
