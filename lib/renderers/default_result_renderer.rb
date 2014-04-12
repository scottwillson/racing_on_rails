require "tabular"

module Renderers
  class DefaultResultRenderer < Tabular::Renderer
    def self.render_header(column)
      case key(column)
      when :bar
        "BAR"
      when :category_name
        "Category"
      when :category_class
        "Class"
      when :event_date_range_s
        "Date"
      when :event_full_name
        "Event"
      when :license
        "Lic"
      when :number
        "Num"
      when :points_bonus
        "Bonus"
      when :place
        ""
      when :points_penalty
        "Penalty"
      when :points_from_place
        "Finish Pts"
      when :points_total
        "Total Pts"
      when :race_name
        "Category"
      when :state
        "ST"
      when :team_name
        "Team"
      when :time_bonus_penalty
        "Bon/Pen"
      when :time_gap_to_leader, :time_gap_to_winner
        "Down"
      when :time_total
        "Overall"
      else
        key(column).to_s.titleize
      end
    end
    
    def self.css_class(column, row = nil)
      case column.key
      when :event_full_name
        "event"
      when :race_name
        "category"
      when :event_date_range_s
        "date hidden-xs"
      else
        key(column).to_s
      end
    end

    def self.key(column)
      if column.respond_to?(:key)
        key = column.key
      else
        key = column
      end
    end
    
    def self.path_prefix(row)
      if row.metadata[:mobile_request]
        "/m"
      end
    end
  end
end
