module GridHelper
  @@grid_columns = nil

  # Class-scope Hash of Columns, keyed by field
  # Used to display results in a grid
  # TODO Rewrite this a bit smarter
  def grid_columns(column)
    if @@grid_columns.nil?
      @@grid_columns = Hash.new
      @@grid_columns['age'] = Column.new(:name => 'age', :description => 'Age', :size => 3, :fixed_size => true)
      @@grid_columns['category_name'] = Column.new(:name => 'category_name', :description => 'Category', :size => 20, :fixed_size => true)
      @@grid_columns['city'] = Column.new(:name => 'city', :description => 'City', :size => 15, :fixed_size => true)
      @@grid_columns['date_of_birth'] = Column.new(:name => 'date_of_birth', :description => 'Date of Birth', :size => 15)
      @@grid_columns['first_name'] = Column.new(:name => 'first_name', :description => 'First Name', :size => 12, :fixed_size => true)
      @@grid_columns['first_name'].link = 'link_to_result(cell, result)'
      @@grid_columns['laps'] = Column.new(:name => 'laps', :description => 'Laps', :size => 4, :fixed_size => true, :justification => Column::RIGHT)
      @@grid_columns['last_name'] = Column.new(:name => 'last_name', :description => 'Last Name', :size => 18, :fixed_size => true)
      @@grid_columns['last_name'].link = 'link_to_result(cell, result)'
      @@grid_columns['license'] = Column.new(:name => 'license', :description => 'Lic', :size => 7)
      @@grid_columns['name'] = Column.new(:name => 'name', :description => 'Name', :size => 30, :fixed_size => true)
      @@grid_columns['name'].link = 'link_to_result(cell, result)'
      @@grid_columns['notes'] = Column.new(:name => 'notes', :description => 'Notes', :size => 12)
      @@grid_columns['number'] = Column.new(:name => 'number', :description => 'Num', :size => 4, :justification => Column::RIGHT)
      @@grid_columns['number'].link = 'link_to_result(cell, result)'
      @@grid_columns['place'] = Column.new(:name => 'place', :description => 'Pl', :size => 3, :fixed_size => true, :justification => Column::RIGHT)
      @@grid_columns['points'] = Column.new(:name => 'points', :description => 'Points', :size => 6, :fixed_size => true, :justification => Column::RIGHT)
      @@grid_columns['points_bonus'] = Column.new(:name => 'points_bonus', :description => 'Bonus', :size => 6, :fixed_size => true, :justification => Column::RIGHT)
      @@grid_columns['points_penalty'] = Column.new(:name => 'points_penalty', :description => 'Penalty', :size => 7, :fixed_size => true, :justification => Column::RIGHT)
      @@grid_columns['points_from_place'] = Column.new(:name => 'points_from_place', :description => 'Finish Pts', :size => 10, :fixed_size => true, :justification => Column::RIGHT)
      @@grid_columns['points_total'] = Column.new(:name => 'points_total', :description => 'Total Pts', :size => 10, :fixed_size => true, :justification => Column::RIGHT)
      @@grid_columns['state'] = Column.new(:name => 'state', :description => 'ST', :size => 3)
      @@grid_columns['team_name'] = Column.new(:name => 'team_name', :description => 'Team', :size => 40)
      @@grid_columns['time'] = Column.new(:name => 'time', :description => 'Time', :size => 8, :justification => Column::RIGHT)
      @@grid_columns['time'].field = :time_s
      @@grid_columns['time_bonus_penalty'] = Column.new(:name => 'time_bonus_penalty', :description => 'Bon/Pen', :size => 7, :justification => Column::RIGHT)
      @@grid_columns['time_bonus_penalty'].field = :time_bonus_penalty_s
      @@grid_columns['time_gap_to_leader'] = Column.new(:name => 'time_gap_to_leader', :description => 'Down', :size => 6, :justification => Column::RIGHT)
      @@grid_columns['time_gap_to_leader'].field = :time_gap_to_leader_s
      @@grid_columns['time_total'] = Column.new(:name => 'time_total', :description => 'Overall', :size => 8, :justification => Column::RIGHT)
      @@grid_columns['time_total'].field = :time_total_s
    end
    grid_column = @@grid_columns[column.to_s]
    if grid_column.nil?
      grid_column = Column.new(:name => column)
      @@grid_columns[column] = grid_column
    end

    # Return a copy so callers can modify column attributes without affecting other clients
    grid_column.dup
  end

  def results_grid(race)
    result_grid_columns = race.result_columns_or_default.collect do |column|
      grid_columns(column)
    end
    rows = race.results.sort.collect do |result|
      row = []
      for grid_column in result_grid_columns
        if grid_column.field and result.respond_to?(grid_column.field)
          cell = result.send(grid_column.field).to_s
          cell = '' if cell == '0.0'
          row << cell
        else
          row << ''
        end
      end
      row
    end
    results_grid = Grid.new(rows, :columns => result_grid_columns)
    results_grid.truncate_rows
    results_grid.calculate_padding

    race.results.sort.each_with_index do |result, row_index|
      result_grid_columns.each_with_index do |grid_column, index|
        if grid_column.link
          cell = results_grid[row_index][index]
          results_grid[row_index][index] = eval(grid_column.link) unless cell.blank?
        end
      end
    end
    "<pre>#{results_grid.to_s(true)}#{race.notes unless race.notes.blank?}</pre>"
  end
end
