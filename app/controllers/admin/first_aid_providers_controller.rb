# frozen_string_literal: true

module Admin
  # Work assignments for Event. First aid provider and chief official.
  # Officials can view, but not edit, this page.
  class FirstAidProvidersController < Admin::AdminController
    skip_before_action :require_administrator
    before_action :require_administrator_or_official
    helper :table

    def index
      @past_events = (params[:past_events] == "true") || false
      @events = if @past_events
                  SingleDayEvent.current_year
                else
                  SingleDayEvent.today_and_future
                end

      @sort_by = params[:sort_by].presence || "date"

      @events = @events.where(practice: false).where(canceled: false).where(postponed: false)

      respond_to do |format|
        format.html
        format.text { email }
      end
    end

    # Formatted for "who would like to work this race email"
    def email
      rows = @events.collect do |event|
        [event.first_aid_provider, event.date, event.name, event.city_state]
      end
      columns = [%w[ provider date name location ]]
      table = Tabular::Table.new(columns + rows)
      table.renderers[:date] = DateRenderer

      render plain: table.to_space_delimited, content_type: "text/plain"
    end

    protected

    def assign_current_admin_tab
      @current_admin_tab = "First Aid"
    end

    class DateRenderer < Tabular::Renderer
      def self.render(column, row)
        date = row[column.key]
        return nil if date.nil?

        date.strftime("%a %-m/%-d")
      end
    end
  end
end
