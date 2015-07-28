class DeleteJunkNames < ActiveRecord::Migration
  def change
    Person.current = RacingAssociation.current.person

    Person.where("updated_at < ?", 6.months.ago).where(member_from: nil).where(license: nil).select do |p|
      !p.name[" "] &&
      p.results.count == 0 &&
      (!p.respond_to?(:orders) || p.orders.count == 0) &&
      (!p.respond_to?(:line_items) || p.line_items == 0) &&
      p.city.blank? &&
      p.home_phone.blank? &&
      p.team_name.blank? &&
      p.roles.empty? &&
      !p.name.in?(["US Bank", "Scott", "Scott Willson", RacingAssociation.current.name, RacingAssociation.current.short_name, "Speedvagen"]) &&
      (p.created_by.nil? || !p.created_by.name.in?(["Scott Willson", "OBRA Webmaster", "T. Kenji Sugahara", "Candi Murray", "Melanie Rathe", "Omer Kem", "Charlie Wanrer"]))
    end.each do |p|
      say "Destroy #{p.name}"
      p.destroy!
    end
  end
end
