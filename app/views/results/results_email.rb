include ActionView

class ResultsEmail
  
  def initialize(standings)
    @standings = standings
  end
  
  def text
    renderer = ActionView::Base.new("app/views")
    _text = renderer.render("results/email", :standings => @standings)
    _text.strip!
    _text + "\n"
  end
end