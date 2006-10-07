module RacingOnRailsControllerHelper
  @@grid_columns = nil
  
  # TODO Rewrite this a bit smarter
  def grid_columns(column)
    if @@grid_columns.nil?
      @@grid_columns = Hash.new
      @@grid_columns['age'] = Column.new('age', 'Age', 2, true, Column::LEFT)
      @@grid_columns['category_name'] = Column.new('category_name', 'Category', 20, true, Column::LEFT)
      @@grid_columns['city'] = Column.new('city', 'City', 15, true, Column::LEFT)
      @@grid_columns['date_of_birth'] = Column.new('date_of_birth', 'Date of Birth', 15, false, Column::LEFT)
      @@grid_columns['first_name'] = Column.new('first_name', 'First Name', 12, true, Column::LEFT)
      @@grid_columns['first_name'].link = 'link_to(cell, "http://app.obra.org/results/racer/#{result.racer.id}") if result.racer'
      @@grid_columns['last_name'] = Column.new('last_name', 'Last Name', 18, true, Column::LEFT)
      @@grid_columns['last_name'].link = 'link_to(cell, "http://app.obra.org/results/racer/#{result.racer.id}") if result.racer'
      @@grid_columns['license'] = Column.new('license', 'Lic', 7, false, Column::LEFT)
      @@grid_columns['name'] = Column.new('name', 'Name', 30, true, Column::LEFT)
      @@grid_columns['name'].link = 'link_to(cell, "http://app.obra.org/results/racer/#{result.racer.id}") if result.racer'
      @@grid_columns['notes'] = Column.new('notes', '', 12, false, Column::LEFT)
      @@grid_columns['number'] = Column.new('number', 'Num', 4, true, Column::LEFT)
      @@grid_columns['number'].link = 'link_to(cell, "http://app.obra.org/results/racer/#{result.racer.id}") if result.racer'
      @@grid_columns['place'] = Column.new('place', '', 3, true, Column::RIGHT)
      @@grid_columns['points'] = Column.new('points', 'Points', 6, true, Column::RIGHT)
      @@grid_columns['state'] = Column.new('state', 'ST', 3, false, Column::LEFT)
      @@grid_columns['team_name'] = Column.new('team_name', 'Team', 40, false, Column::LEFT)
      @@grid_columns['time'] = Column.new('time', 'Time', 8, false, Column::RIGHT)
      @@grid_columns['time'].field = :time_s
      @@grid_columns['time_bonus_penalty'] = Column.new('time_bonus_penalty', 'Bon/Pen', 7, false, Column::RIGHT)
      @@grid_columns['time_bonus_penalty'].field = :time_bonus_penalty_s
      @@grid_columns['time_gap_to_leader'] = Column.new('time_gap_to_leader', 'Down', 6, false, Column::RIGHT)
      @@grid_columns['time_gap_to_leader'].field = :time_gap_to_leader_s
      @@grid_columns['time_total'] = Column.new('time_total', 'Overall', 8, false, Column::RIGHT)
      @@grid_columns['time_total'].field = :time_total_s
    end
    grid_column = @@grid_columns[column]
    if grid_column.nil?
      grid_column = Column.new(column)
      @@grid_columns[column] = grid_column
    end
    grid_column
  end

  def attribute(record, name)
    render(:partial => '/admin/attribute', :locals => {:record => record, :name => name})
  end
end