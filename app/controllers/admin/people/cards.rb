module Admin
  module People
    module Cards
      extend ActiveSupport::Concern

      # Membership card stickers/labels
      def cards
        @people = Person.where(print_card: true).order("last_name, first_name").includes(:race_numbers).sort_by { |p| p.road_number || "" }

        ActiveSupport::Notifications.instrument "cards.people.admin.racing_on_rails", person_count: @people.count

        if @people.empty?
          return redirect_to(no_cards_admin_people_path(format: "html"))
        else
          Person.where(id: @people.map(&:id)).update_all(print_card: 0, membership_card: 1)
        end

        respond_to do |format|
          format.pdf do
            send_data Card.new.to_pdf(@people),
                      filename: "cards.pdf",
                      type: "application/pdf"
          end
        end
      end

      # Single membership card
      def card
        @person = Person.find(params[:id])
        @people = [ @person ]
        @person.print_card!

        ActiveSupport::Notifications.instrument "card.people.admin.racing_on_rails", person_id: @person.id

        respond_to do |format|
          format.pdf do
            send_data Card.new.to_pdf(@person),
                      filename: "card.pdf",
                      type: "application/pdf"
          end
        end
      end
    end
  end
end
