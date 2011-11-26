module Ages
  # Return Range
  def ages
    ages_begin..ages_end
  end

  # Accepts an age Range like 10..18, or a String like 10-18
  def ages=(value)
    case value
    when Range
      self.ages_begin = value.begin
      self.ages_end = value.end
    else
      age_split = value.strip.split('-')
      self.ages_begin = age_split[0].to_i unless age_split[0].nil?
      self.ages_end = age_split[1].to_i unless age_split[1].nil?
    end
  end    
end
