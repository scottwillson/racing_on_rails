module ScheduleHelper  
  def cherry_pie_coutdown
    coutdown = Builder::XmlMarkup.new( :indent => 2)
    coutdown.flash {
      coutdown.text!("Only #{Date.new(2010, 2, 20) - Date.today} days until the 2010 Cherry Pie Road Race!!!")
    }
    coutdown
  end
end