class SetCorrectTypeForOldEvents < ActiveRecord::Migration
  def self.up
    Bar.find(:all, :conditions => ["date < ?", Date.new(2009)]).each do |discipline_bar_parent|
      discipline_bar_parent.children.each do |discipline_bar|
        discipline_bar.parent = nil
        discipline_bar.discipline = discipline_bar.name
        discipline_bar.name = "#{discipline_bar.year} #{discipline_bar.discipline} BAR"
        discipline_bar.type = "Bar"
        discipline_bar.save!
      end
      discipline_bar_parent.children(true)
      discipline_bar_parent.destroy
    end
    
    AgeGradedBar.update_all("discipline = 'Age Graded'")
    
    if ASSOCIATION.short_name == "OBRA"
      Event.find([14320, 14706, 14542]).each do |cross_crusade_overall|
        cross_crusade_overall.type = "CrossCrusadeOverall"
        cross_crusade_overall.save!
      end
      
      tabor_overall_2008 = Event.find(14319)
      tabor_overall_2008.type = "TaborOverall"
      tabor_overall_2008.save!
    end
    
    if ASSOCIATION.short_name == "WSBA"
      execute "update events set type = 'CascadeCrossOverall' where id = 655"
    end
  end
end
