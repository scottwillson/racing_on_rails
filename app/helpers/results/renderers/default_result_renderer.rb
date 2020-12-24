# frozen_string_literal: true

module Results
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
        when :license, :usac_license
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

      def self.css_class(column, _row = nil)
        case column.key
        when :event_full_name
          "event"
        when :race_name
          "category"
        when :event_date_range_s
          "date"
        when /time/
          "time"
        # team_name should be for team results only
        when :name, :place, :points, :team_name
          key(column).to_s
        else
          "#{key(column)}"
        end
      end

      def self.render(column, row)
        if key(column) && key(column)["time"]
          TimeRenderer.render column, row
        else
          super
        end
      end

      def self.key(column)
        if column.respond_to?(:key)
          column.key
        else
          column
        end
      end
    end
  end
end
