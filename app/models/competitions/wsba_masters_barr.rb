class WsbaMastersBarr < WsbaBarr
  def friendly_name
    "WSBA Masters BARR"
  end
  
  def point_schedule
    [ 0, 20, 17, 15, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2 ]
  end

  def create_races
    [
      "Master Men 35-39 Cat 1-3",
      "Master Men 35-39 Cat 4-5",
      "Master Men 40-49 Cat 1-3",
      "Master Men 40-49 Cat 4-5",
      "Master Men 50+ Cat 1-5",
      "Master Women 35+ Cat 1-3",
      "Master Women 35+ Cat 4"
    ].each do |category_name|
      category = Category.find_or_create_by_name(category_name)
      races.create(:category => category)
    end
  end

  def points_for(source_result, team_size = nil)
    points = 0
    WsbaBarr.benchmark('points_for', :level => "debug") {
      results_in_place = Result.count(:conditions => ["race_id =? and place = ?", source_result.race.id, source_result.place])
      if team_size.nil?
        # assume this is a TTT, score divided by 4 regardless of # of riders
        team_size = (results_in_place > 1) ? 4 : 1 
      end
      points_index = place_members_only? ? source_result.members_only_place.to_i : source_result.place.to_i
      points = point_schedule[points_index].to_f
      points /= team_size.to_f 
    }
    points
  end
end
