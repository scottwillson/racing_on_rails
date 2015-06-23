class FixDupeLicenses < ActiveRecord::Migration
  def change
    Person.current = RacingAssociation.current.person

    Person.transaction do
      Person.where(license: "").update_all(license: nil)

      licenses = Person.
                  where("license is not null").
                  where("license != ''").
                  group("cast(license as unsigned)").
                  having("count(cast(license as unsigned)) > 1").
                  pluck(:license)

      Person.where(license: licenses).includes(:versions).group_by { |p| p.license.to_i }.each do |license, people|
        most_recent_member = people.select(&:member_to).sort_by(&:member_to).last || people.last
        say "#{most_recent_member.name} keeps license #{license}"
        (people - [ most_recent_member ]).each do |person|
          say "#{person.name} license set to blank"
          person.license = nil;
          person.save!
        end
      end
    end
  end
end
