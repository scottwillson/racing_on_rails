class BlindDateAtTheDairyOverall < Overall
  def self.parent_event_name
    "Blind Date at the Dairy"
  end

  def category_names
    [
      "Junior Men 10-13",
      "Junior Men 14-18",
      "Junior Women 10-13",
      "Junior Women 14-18",
      "Masters Men A 40+",
      "Masters Men B 35+",
      "Masters Men C 35+",
      "Men A",
      "Men B",
      "Men C",
      "Singlespeed",
      "Women A",
      "Women B",
      "Women C"
    ]
  end

  def default_bar_points
    1
  end

  def point_schedule
    [ 0, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]
  end
end
