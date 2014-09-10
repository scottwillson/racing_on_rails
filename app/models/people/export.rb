module People
  module Export
    extend ActiveSupport::Concern

    included do
      # Flattened, straight SQL dump for export to Excel, FinishLynx, or SportsBase.
      def self.find_all_for_export(date = Time.zone.today, include_people = "members_only")
        association_number_issuer_id = NumberIssuer.find_by_name(RacingAssociation.current.short_name).id
        if include_people == "members_only"
          where_clause = "WHERE (member_to >= '#{date}')"
        elsif include_people == "print_cards"
          where_clause = "WHERE  (member_to >= '#{date}') and print_card is true"
        end

        people = Person.connection.select_all(%Q{
          SELECT people.id, license, first_name, last_name, teams.name as team_name, team_id, people.notes,
                 member_from, member_to, member_usac_to,
                 (member_from IS NOT NULL AND member_to IS NOT NULL AND member_from <= NOW() AND member_to >= NOW()) as member,
                 print_card, card_printed_at, membership_card, ccx_only, date_of_birth, occupation,
                 street, people.city, people.state, zip, wants_mail, email, wants_email, home_phone, work_phone, cell_fax, gender,
                 ccx_category, road_category, track_category, mtb_category, dh_category,
                 volunteer_interest, official_interest, race_promotion_interest, team_interest,
                 CEILING(#{date.year} - YEAR(date_of_birth)) as racing_age,
                 ccx_numbers.value as ccx_number, dh_numbers.value as dh_number, road_numbers.value as road_number,
                 singlespeed_numbers.value as singlespeed_number, xc_numbers.value as xc_number,
                 people.created_at, people.updated_at
          FROM people
          LEFT OUTER JOIN teams ON teams.id = people.team_id
          LEFT OUTER JOIN race_numbers as ccx_numbers ON ccx_numbers.person_id = people.id
                          and ccx_numbers.number_issuer_id = #{association_number_issuer_id}
                          and ccx_numbers.year = #{date.year}
                          and ccx_numbers.discipline_id = #{Discipline[:cyclocross].id}
          LEFT OUTER JOIN race_numbers as dh_numbers ON dh_numbers.person_id = people.id
                          and dh_numbers.number_issuer_id = #{association_number_issuer_id}
                          and dh_numbers.year = #{date.year}
                          and dh_numbers.discipline_id = #{Discipline[:downhill].id}
          LEFT OUTER JOIN race_numbers as road_numbers ON road_numbers.person_id = people.id
                          and road_numbers.number_issuer_id = #{association_number_issuer_id}
                          and road_numbers.year = #{date.year}
                          and road_numbers.discipline_id = #{Discipline[:road].id}
          LEFT OUTER JOIN race_numbers as singlespeed_numbers ON singlespeed_numbers.person_id = people.id
                          and singlespeed_numbers.number_issuer_id = #{association_number_issuer_id}
                          and singlespeed_numbers.year = #{date.year}
                          and singlespeed_numbers.discipline_id = #{Discipline[:singlespeed].id}
          LEFT OUTER JOIN race_numbers as track_numbers ON track_numbers.person_id = people.id
                          and track_numbers.number_issuer_id = #{association_number_issuer_id}
                          and track_numbers.year = #{date.year}
                          and track_numbers.discipline_id = #{Discipline[:track].id}
          LEFT OUTER JOIN race_numbers as xc_numbers ON xc_numbers.person_id = people.id
                          and xc_numbers.number_issuer_id = #{association_number_issuer_id}
                          and xc_numbers.year = #{date.year}
                          and xc_numbers.discipline_id = #{Discipline[:mountain_bike].id}
          #{where_clause}
          ORDER BY last_name, first_name, people.id
        })

        last_person = nil
        people.to_a.reject do |person|
          if last_person && last_person["id"] == person["id"]
            true
          else
            last_person = person
            false
          end
        end
      end
    end
  end
end
