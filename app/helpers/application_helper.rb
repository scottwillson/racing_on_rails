# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  @@grid_columns = nil
    
  def focus(form_field_name)
    @focus = form_field_name
  end
  
  def aka(racer)
    unless racer.aliases.empty?
      aliases = racer.aliases.collect {|a| a.name}
      "(a.k.a. #{aliases.join(', ')})"
    end
  end
  
  # Wrap +text+ in div tags, unless +text+ is blank
  def div(text)
    "<div>#{text}</div>" unless text.blank?
  end

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
      @@grid_columns['last_name'] = Column.new(:name => 'last_name', :description => 'Last Name', :size => 18, :fixed_size => true)
      @@grid_columns['last_name'].link = 'link_to_result(cell, result)'
      @@grid_columns['license'] = Column.new(:name => 'license', :description => 'Lic', :size => 7)
      @@grid_columns['name'] = Column.new(:name => 'name', :description => 'Name', :size => 30, :fixed_size => true)
      @@grid_columns['name'].link = 'link_to_result(cell, result)'
      @@grid_columns['notes'] = Column.new(:name => 'notes', :description => 'Notes', :size => 12)
      @@grid_columns['number'] = Column.new(:name => 'number', :description => 'Num', :size => 4, :fixed_size => true)
      @@grid_columns['number'].link = 'link_to_result(cell, result)'
      @@grid_columns['place'] = Column.new(:name => 'place', :description => 'Pl', :size => 3, :fixed_size => true, :justification => Column::RIGHT)
      @@grid_columns['points'] = Column.new(:name => 'points', :description => 'Points', :size => 6, :fixed_size => true, :justification => Column::RIGHT)
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
    grid_column = @@grid_columns[column]
    if grid_column.nil?
      grid_column = Column.new(:name => column)
      @@grid_columns[column] = grid_column
    end
    
    # Return a copy so callers can modify column attributes without affecting other clients
    grid_column.dup
  end
  
  def link_to_result(cell, result)
    return unless result.racer

    if result.competition_result?
      link_to(cell, 
        :controller => 'results',
        :action => 'competition',
        :competition_id => result.race.standings.event.to_param,
        :racer_id => result.racer_id)
    else
      link_to(cell, "/results/racer/#{result.racer.id}")
    end
  end

  # Should field from model object displayed by a RecordEditor
  # TODO: Move to Admin::RecordEditor?
  def attribute(record, name)
    render(:partial => '/admin/attribute', :locals => {:record => record, :name => name})
  end
  
  def tabs(select_current_page = true)
    tabs = Tabs.new(@controller)
    yield tabs
    tabs.to_html(select_current_page)
  end
  
  def image(name)
    return '' if name.blank?
    
    img = Image.find_by_name(name)
    return '' unless img

    if img.link
      eval("link_to(image_tag(img.source #{', ' + img.html_options unless img.html_options.blank? }), #{img.link}, {:class => 'image'})")
    else
      image_tag(img.source)
    end
  end
  
  def caption(name)
    return '' if name.blank?
    
    img = Image.find_by_name(name)
    return '' unless img

    if img.caption.blank?
      ''
    else
      eval(img.caption)
    end
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

class Tabs
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  
  def initialize(controller)
    @controller = controller
    @tabs = []
  end
  
  def add(name, options = {}, html_options = {}, &block)
    _html_options = {:onmouseover => "hover(this)", :onmouseout => "hoverOut(this)"}
    _html_options.merge(html_options) if html_options
    @tabs << [name, options, _html_options]
  end
  
  def select(name)
    @selected_name = name
  end
  
  # Builder escapes text, which is not what we want
  def to_html(select_current_page = true)
    table_class = "tabs"
    table_class = "tabs_solo" if @tabs.size < 2
    html = <<HTML
<div style="text-align: center;">
  <table class="#{table_class}">
    <tr>
HTML
    @tabs.each_with_index do |tab, index|
      if index == 0
        if select_current_page && current_page?(tab[1])
          html << "      <td class=\"first_selected\"><div class=\"first_selected\"><span>"
        else
          html << "      <td class=\"first\"><div class=\"first\"><span>"
        end
        if select_current_page
          html << link_to_unless_current(tab.first, tab[1], tab[2]).to_s
        else
          html << link_to(tab.first, tab[1], tab[2]).to_s
        end
        html << "</span></div>"
        if @tabs.size < 2
          if select_current_page && current_page?(tab[1])
            html << "</td>\n      <td class=\"last_selected\"><div class=\"last_selected\">"
            html << "<span>&nbsp;</span></div>"
          else
            html << "</td>\n      <td class=\"last\"><div class=\"last\"><span>&nbsp;</span></div>"
          end
        end
      elsif index == @tabs.size - 1
        if select_current_page && current_page?(tab[1])
          html << "      <td class=\"last_selected\"><div class=\"last_selected\"><span>"
        else
          html << "      <td class=\"last\"><div class=\"last\"><span>"
        end
        if select_current_page
          html << link_to_unless_current(tab.first, tab[1], tab[2]).to_s
        else
          html << link_to(tab.first, tab[1], tab[2]).to_s
        end
        html << "</span></div>"
      else
        if select_current_page && current_page?(tab[1])
          html << "      <td class=\"selected\"><div class=\"selected\"><span>"
        else
          html << "      <td><div><span>"
        end
        if select_current_page
          html << link_to_unless_current(tab.first, tab[1], tab[2]).to_s
        else
          html << link_to(tab.first, tab[1], tab[2]).to_s
        end
        html << "</span></div>"
      end
      html << "</td>\n"
    end
    end_html = <<HTML
    </tr>
  </table>
</div>
HTML
    html << end_html
  end
end
