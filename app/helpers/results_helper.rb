module ResultsHelper
  # TODO Move to module in Race?
  RESULT_COLUMNS = %W{ place number name team_name age_group category_class category_name points_bonus points_bonus_penalty points_from_place points_penalty points_total time_bonus_penalty time_gap_to_leader time_gap_to_previous time_gap_to_winner points laps time time_total notes }.freeze

  # results for pagination
  def results_table(race, results = nil)
    return "" unless race

    table = Tabular::Table.new
    
    if mobile_request?
      if race.event.respond_to?(:team?) && race.event.team?
        table.row_mapper = RacingOnRails::Tabular::Mapper.new(%w{ place team_name })
      else
        table.row_mapper = RacingOnRails::Tabular::Mapper.new(%w{ place name })
      end
    else
      table.row_mapper = RacingOnRails::Tabular::Mapper.new(
                           %W{ place number name team_name }, 
                           race.try(:custom_columns), 
                           RESULT_COLUMNS - %W{ place name team_name }
                         )
    end

    if results
      table.rows = results.sort
    else
      table.rows = race.results.sort
    end
    
    # Minor speed improvement
    unless mobile_request?
      table.delete_blank_columns!
      table.delete_homogenous_columns!
    end

    table.renderer = Renderers::DefaultResultRenderer
    table.renderers[:name] = Renderers::NameRenderer
    table.renderers[:team_name] = Renderers::TeamNameRenderer
    table.renderers[:time] = Renderers::TimeRenderer
    table.renderers[:time_bonus_penalty] = Renderers::TimeRenderer
    table.renderers[:time_gap_to_leader] = Renderers::TimeRenderer
    table.renderers[:time_gap_to_previous] = Renderers::TimeRenderer
    table.renderers[:time_gap_to_winner] = Renderers::TimeRenderer
    table.renderers[:time_total] = Renderers::TimeRenderer
    table.renderers[:points] = Renderers::PointsRenderer
    table.renderers[:points_bonus] = Renderers::PointsRenderer
    table.renderers[:points_bonus_penalty] = Renderers::PointsRenderer
    table.renderers[:points_from_place] = Renderers::PointsRenderer
    table.renderers[:points_penalty] = Renderers::PointsRenderer
    table.renderers[:points_total] = Renderers::PointsRenderer
    render "results/table", :table => table, :css_class => "results"
  end

  def participant_event_results_table(participant, event_results)
    table = Tabular::Table.new

    case participant
    when Person
      if mobile_request?
        table.row_mapper = RacingOnRails::Tabular::Mapper.new(%w{ place event_full_name })
      else
        table.row_mapper = RacingOnRails::Tabular::Mapper.new(%w{ place event_full_name race_name event_date_range_s })
      end
    when Team
      if mobile_request?
        table.row_mapper = RacingOnRails::Tabular::Mapper.new(%w{ place event_full_name name })
      else
        table.row_mapper = RacingOnRails::Tabular::Mapper.new(%w{ place event_full_name race_name name event_date_range_s })
      end
    else
      raise ArgumentError, "participant must be a Person or Team but was #{participant.class}"
    end

    table.rows = event_results.sort_by(&:date).reverse
    table.renderer = Renderers::DefaultResultRenderer
    table.renderers[:event_full_name] = Renderers::EventFullNameRenderer
    table.renderers[:points] = Renderers::PointsRenderer
    render "results/table", :table => table, :css_class => "results"
  end

  def scores_table(result)
    table = Tabular::Table.new

    if result.team_competition_result?
      if mobile_request?
        table.row_mapper = RacingOnRails::Tabular::Mapper.new(%w{ place event_full_name name })
      else
        table.row_mapper = RacingOnRails::Tabular::Mapper.new(%w{ place event_full_name race_name name event_date_range_s points })
      end
    else
      if mobile_request?
        table.row_mapper = RacingOnRails::Tabular::Mapper.new(%w{ place event_full_name })
      else
        table.row_mapper = RacingOnRails::Tabular::Mapper.new(%w{ place event_full_name race_name event_date_range_s points })
      end
    end

    table.rows = result.scores.sort_by { |score| score.source_result.date }.map do |score|
      source_result = score.source_result
      source_result.points = score.points
      source_result
    end
    table.rows << Tabular::Row.new(table, :points => result.points)
    table.renderer = Renderers::DefaultResultRenderer
    table.renderers[:event_full_name] = Renderers::ScoreEventFullNameRenderer
    table.renderers[:points] = Renderers::PointsRenderer
    render "results/table", :table => table, :css_class => "results scores"
  end

  def edit_results_table(race)
    table = Tabular::Table.new
    table.row_mapper = RacingOnRails::Tabular::Mapper.new(RESULT_COLUMNS, race.custom_columns)

    table.rows = race.results.sort

    table.delete_blank_columns!
    table.delete_homogenous_columns!

    table.renderer = Renderers::DefaultResultRenderer
    table.renderers[:time] = Renderers::TimeRenderer
    table.renderers[:time_bonus_penalty] = Renderers::TimeRenderer
    table.renderers[:time_gap_to_leader] = Renderers::TimeRenderer
    table.renderers[:time_gap_to_previous] = Renderers::TimeRenderer
    table.renderers[:time_gap_to_winner] = Renderers::TimeRenderer
    table.renderers[:time_total] = Renderers::TimeRenderer
    table.renderers[:points] = Renderers::PointsRenderer
    table.renderers[:points_bonus] = Renderers::PointsRenderer
    table.renderers[:points_bonus_penalty] = Renderers::PointsRenderer
    table.renderers[:points_from_place] = Renderers::PointsRenderer
    table.renderers[:points_penalty] = Renderers::PointsRenderer
    table.renderers[:points_total] = Renderers::PointsRenderer

    table.columns << :bar
    
    render "admin/races/results", :results_table_for_race => table, :race => race, :css_class => "results"
  end
end
