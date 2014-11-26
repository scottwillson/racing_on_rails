module Admin
  module People
    module Export
      extend ActiveSupport::Concern

      # == Params
      # * excel_layout: "scoring_sheet" for fewer columns -- intended for scoring race results. "endicia" for card stickers.
      # * include: "print_cards"
      # * format: "ppl" for FinishLynx scoring
      def export
        headers['Content-Disposition'] = "filename=\"#{download_file_name(current_date)}\""

        @people = Person.find_all_for_export(current_date, params['include'])

        ActiveSupport::Notifications.instrument(
          "export.people.admin.racing_on_rails",
          people_count: @people.size,
          excel_layout:
          params[:excel_layout],
          format: params[:format]
        )

        respond_to do |format|
          format.html
          format.ppl
          format.xls {
            if params['excel_layout'] == 'scoring_sheet'
              render 'admin/people/scoring_sheet'
            elsif params['excel_layout'] == 'endicia'
              render 'admin/people/endicia'
            end
          }
        end
      end

      protected

      def download_file_name(date)
        if params["excel_layout"] == "scoring_sheet"
          "scoring_sheet.xls"
        elsif params["include"] == "print_cards"
          "print_cards.xls"
        elsif params["format"] == "ppl"
          "lynx.ppl"
        else
          "people_#{date.year}_#{date.month}_#{date.day}.#{params['format']}"
        end
      end
    end
  end
end
