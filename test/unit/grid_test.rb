require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class GridTest < ActiveSupport::TestCase
  def test_new
    Grid.new
  end
  
  def test_new_empty_text
    text = ""
    grid = Grid.new(text)
    assert_equal(0, grid.column_count, "column count")
    assert_equal(0, grid.row_count, "row count")
    assert_equal(0, grid.column_size(0), "column 0 size")
    assert_equal(0, grid.column_size(90), "column 90 size")
    assert_equal("", grid.to_s, "to_s")

    grid = Grid.new(text, :header_row => true)
    assert_equal(0, grid.column_count, "column count")
    assert_equal(0, grid.row_count, "row count")
    assert_equal(0, grid.column_size(0), "column 0 size")
    assert_equal(0, grid.column_size(90), "column 90 size")
    assert_equal("", grid.to_s, "to_s")
  end
  
  def test_new_one_line_text
    text = "1\t001\tChris Horner\tSaunier\t9"
    grid = Grid.new(text)
    assert_equal(5, grid.column_count, "column count")
    assert_equal(1, grid.row_count, "row count")
    assert_equal(1, grid.column_size(0), "column 0 size")
    assert_equal(12, grid.column_size(2), "column 2 size")
    assert_equal("1", grid[0][0], "grid[0][0]")
    assert_equal("9", grid[0][4], "grid[0][4]")
    assert_equal("", grid[0][18], "grid[0][18]")
    assert_equal("1   001   Chris Horner   Saunier   9\n", grid.to_s, "to_s")
  end
  
  def test_new_many_lines
    text = <<END
      Place \tNumber\tLast Name\tFirst Name\tTeam\tCategory Raced
      1\t189\tWillson\tScott\tGentle Lover\tSenior Men 1/2/3\t11\t\t11
      2\t190\tPhinney\tHarry\tCCCP\tSenior Men 1/2/3\t9\t\t
      3\t10a\tHolland\tSteve\tHuntair\tSenior Men 1/2/3\t\t3\t
      dnf\t100\tBourcier\tPaul\tHutch's\tSenior Men 1/2/3\t\t\t1
END
    grid = Grid.new(text)
    assert_equal(9, grid.column_count, "column count")
    assert_equal(5, grid.row_count, "row count")
    assert_equal(6, grid.column_size(1), "column 1 size")
    assert_equal(9, grid.column_size(2), "column 2 size")
    assert_equal("1", grid[1][0], "grid[1][0]")
    assert_equal("CCCP", grid[2][4], "grid[2][4]")
    assert_equal("", grid[3][18], "grid[3][18]")
    expected_text = <<END
Place   Number   Last Name   First Name   Team           Category Raced                
1       189      Willson     Scott        Gentle Lover   Senior Men 1/2/3   11       11
2       190      Phinney     Harry        CCCP           Senior Men 1/2/3   9          
3       10a      Holland     Steve        Huntair        Senior Men 1/2/3        3     
dnf     100      Bourcier    Paul         Hutch's        Senior Men 1/2/3            1 
END
    assert_equal(expected_text, grid.to_s, "to_s")
  end
  
  def test_new_array
    text = [
      "Place \tNumber\tLast Name\tFirst Name\tTeam\tCategory Raced\n",
      "1\t189\tWillson\tScott\tGentle Lover\tSenior Men 1/2/3\t11\t\t11\n",
      "2\t190\tPhinney\tHarry\tCCCP\tSenior Men 1/2/3\t9\t\t\n",
      "3\t10a\tHolland\tSteve\tHuntair\tSenior Men 1/2/3\t\t3\t\n",
      "dnf\t100\tBourcier\tPaul\tHutch's\tSenior Men 1/2/3\t\t\t1\n"
    ]
    grid = Grid.new(text)
    assert_equal(9, grid.column_count, "column count")
    assert_equal(5, grid.row_count, "row count")
    assert_equal(6, grid.column_size(1), "column 1 size")
    assert_equal(9, grid.column_size(2), "column 2 size")
    assert_equal("1", grid[1][0], "grid[1][0]")
    assert_equal("CCCP", grid[2][4], "grid[2][4]")
    assert_equal("", grid[3][18], "grid[3][18]")
  end
  
  def test_set_value
    columns = ["place", "number", "person.last_name", "person.first_name", "team.name", "person.category"]
    text = <<END
      1\t189\tWillson\tScott\tGentle Lover\tSenior Men 1/2/3\t11\t\t11
      2\t190\tPhinney\tHarry\tCCCP\tSenior Men 1/2/3\t9\t\t
      3\t10a\tHolland\tSteve\tHuntair\tSenior Men 1/2/3\t\t3\t
      dnf\t100\tBourcier\tPaul\tHutch's\tSenior Men 1/2/3\t\t\t1
END
    grid = Grid.new(text, :columns => columns)
    assert_equal("CCCP", grid[1][4], "grid[1][4]")
    grid[1][4] = "Gentle Lovers"
    assert_equal("Gentle Lovers", grid[1][4], "grid[1][4]")
    grid[1][4] = nil
    assert_equal("", grid[1][4], "grid[1][4]")
  end
  
  def test_columns
    columns = ["Place", "Number", "Last Name", "First Name", "Team", "Category Raced"]
    text = <<END
      1\t189\tWillson\tScott\tGentle Lover\tSenior Men 1/2/3\t11\t\t11
      2\t190\tPhinney\tHarry\tCCCP\tSenior Men 1/2/3\t9\t\t
      3\t10a\tHolland\tSteve\tHuntair\tSenior Men 1/2/3\t\t3\t
      dnf\t100\tBourcier\tPaul\tHutch's\tSenior Men 1/2/3\t\t\t1
END
    grid = Grid.new(text, :columns => columns)
    assert_equal(9, grid.column_count, "column count #{grid.columns.join(', ')}")
    assert_equal(:last_name, grid.columns[2].field, "third column field")
    assert_equal("Last Name", grid.columns[2].name, "third column name")
    assert_equal("Huntair", grid[2][4], "grid[2][4]")
    assert_equal("Huntair", grid[2]["Team"], "grid[2][""Team""]")
    assert_equal("", grid[2]["Weight"], "grid[2][""Weight""]")
  end

  def test_empty_to_s_text
    text = ""
    columns = [
      Column.new(:name => 'place', :description => '', :size => 3, :fixed_size => true, :justification => Column::RIGHT),
      Column.new(:name => 'number', :description => 'Number', :size => 5, :fixed_size => true),
      Column.new(:name => 'last_name', :description => 'Last Name', :size => 15, :fixed_size => true)
    ]
    grid = Grid.new(text, :columns => columns)
    assert_equal(3, grid.column_count, "column count")
    assert_equal(0, grid.row_count, "row count")
    assert_equal(5, grid.column_size(1), "column 1 size")
    assert_equal(0, grid.column_size(90), "column 90 size")
    assert_equal("      Nu...   Last Name      \n", grid.to_s, "to_s")
    assert_equal("", grid.to_s(false), "to_s")
  end

    def test_column_formatting
      text = <<END
        1\t189\tWillson\tScott\tGentle Lover\tSenior Men 1/2/3\t11\t\t11
        2\t190\tPhinney-Carpenter\tHarry\tCCCP\tSenior Men 1/2/3\t9\t\t
        3\t10a\tHolland\tSteve\tHuntair\tSenior Men 1/2/3\t\t3\t
        dnf\t100\tBourcier\tPaul\tHutch's\tSenior Men 1/2/3\t\t\t1
END
      columns = [
        Column.new(:name => 'place', :description => '', :size => 3, :justification => Column::RIGHT),
        Column.new(:name => 'number', :description => 'Number', :size => 5),
        Column.new(:name => 'last_name', :description => 'Last Name', :size => 15, :fixed_size => true),
        Column.new(:name => 'first_name', :description => 'First Name', :size => 12),
        Column.new(:name => 'team_name', :description => 'Team', :size => 30),
        Column.new(:name => 'category', :description => 'Category', :size => 20),
        Column.new(:name => 'points', :description => '', :size => 3, :fixed_size => true, :justification => Column::RIGHT),
        Column.new(:name => 'points_bonus_penalty', :description => '', :size => 3, :fixed_size => true, :justification => Column::RIGHT),
        Column.new(:name => 'points_total', :description => '', :size => 3, :fixed_size => true, :justification => Column::RIGHT)
      ]
      grid = Grid.new(text, :columns => columns)
      assert_equal(9, grid.column_count, "column count")
      assert_equal(4, grid.row_count, "row count")
      assert_equal(6, grid.column_size(1), "column 1 size")
      assert_equal(15, grid.column_size(2), "column 2 size")
      assert_equal("1", grid[0][0], "grid[0][0]")
      assert_equal("CCCP", grid[1][4], "grid[1][4]")
      assert_equal("", grid[2][18], "grid[2][18]")
      expected_text = <<END
      Number   Last Name         First Name     Team                             Category                              
  1   189      Willson           Scott          Gentle Lover                     Senior Men 1/2/3        11          11
  2   190      Phinney-Carp...   Harry          CCCP                             Senior Men 1/2/3         9            
  3   10a      Holland           Steve          Huntair                          Senior Men 1/2/3               3      
dnf   100      Bourcier          Paul           Hutch's                          Senior Men 1/2/3                     1
END
      assert_equal(expected_text, grid.to_s, "to_s")
    end
    
    def test_delete_blank_rows
      columns = ["Place", "Number", "Last Name", "First Name", "Team", "Category Raced", "points"]
      text = <<END
        1\t189\tWillson\tScott\tGentle Lover\tSenior Men 1/2/3\t11\t\t11
        2\t190\tPhinney-Carpenter\tHarry\tCCCP\tSenior Men 1/2/3\t9\t\t
        \t\t\t\t\t\t\t\t 
        3\t10a\tHolland\tSteve\tHuntair\tSenior Men 1/2/3\t\t3\t
        dnf\t100\tBourcier\tPaul\tHutch's\tSenior Men 1/2/3\t\t\t1
        \t\t\t  \t\t\t\t\t
        \t\t\t\t\t\t\t\t
END
grid = Grid.new(text, :columns => columns)
      assert_equal(7, grid.row_count, "row count")
      grid.delete_blank_rows
      assert_equal(4, grid.row_count, "row count")
    end
end