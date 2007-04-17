class AddAssociationCategory < ActiveRecord::Migration
  def self.up
    Category.transaction do
      unknown_categories = Category.find_all_unknowns
      assoc_category = Category.find_or_create_by_name(ASSOCIATION.short_name)
      for category in unknown_categories
        if category.id < 1000
          category.parent = assoc_category
          category.save!
        end
      end

      nonstandard = assoc_category.children.create(:name => 'Nonstandard', :position => 900)
      nonstandard_category_names = ['Retro (M)', 'Retro (W)', 'Combined', 'Team', 'Senior Women Series Standings', 'Ironman', 'Masters Men 40+ Series Standings', 'Senior Men Category 1/2/3 Series Standings', 'Senior Men Category 4/5 Series Standings', 'Recumbent', 'Demonstration', 'Hardtail Open', 'Place', 'HARDTAIL MEN (open)', 'HARDTAIL WOMEN (open)', 'Hardtail Men', 'Hardtail Women', 'Two Person Team', 'Two Person Teams', 'Male Single Speed', 'Team Competition', 'Fastest Couple', 'Hardtail (races Sport Course)', 'Hardtail', 'Other', 'Fixed', 'Hard Tail', 'Demonstration - 500 m TT', 'Recumbent/HPV', 'SSS 12', 'Two Person Mixed 12-20', 'Four Person Men 12-27', 'Sport Men 24-2', 'Exp Men 24-3', 'Master (age 40+) 24-6', 'Women Exp/Pro 24-12', 'Pro/Exp Two Person Men 24-15', 'Two Person Men 24-18', 'Two Person Pro/Exp Women 24-16', 'Pro/Exp Four Person Men 24-24', 'Four Person Men 24-27', 'Four person Single Speed 24-30', 'Women Cat 4 and 40+', 'Unicycle', 'Clydesdale', 'Position Week 2']
      for name in nonstandard_category_names
        category = Category.find_by_name(name)
        if category
          category.parent = nonstandard
          category.save!
        else
          puts("Did not find category '#{name}'")
        end
      end
    end
  end

  def self.down
  end
end

