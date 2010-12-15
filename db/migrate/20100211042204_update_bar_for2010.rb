class UpdateBarFor2010 < ActiveRecord::Migration
  def self.up
    downhill = Discipline[:downhill]
    if downhill
      downhill.bar_categories.clear
      downhill.bar = false
      downhill.save!
    end
    
    short_track = Discipline.create!(:name => "Short Track", :bar => true)
    short_track.bar_categories << Category.find_or_create_by_name("Category 3 Men")
    short_track.bar_categories << Category.find_or_create_by_name("Category 3 Women")
    short_track.bar_categories << Category.find_or_create_by_name("Junior Men")
    short_track.bar_categories << Category.find_or_create_by_name("Junior Women")
    short_track.bar_categories << Category.find_or_create_by_name("Masters Men")
    short_track.bar_categories << Category.find_or_create_by_name("Masters Women")
    short_track.bar_categories << Category.find_or_create_by_name("Singlespeed/Fixed")
    short_track.bar_categories << Category.find_or_create_by_name("Tandem")
    short_track.bar_categories << Category.find_or_create_by_name("Pro Men")
    short_track.bar_categories << Category.find_or_create_by_name("Pro Women")
    short_track.bar_categories << Category.find_or_create_by_name("Category 2 Men")
    short_track.bar_categories << Category.find_or_create_by_name("Category 2 Women")
    short_track.bar_categories << Category.find_or_create_by_name("Category 1 Men")
    short_track.bar_categories << Category.find_or_create_by_name("Category 1 Women")
    
    Discipline.find.all( :conditions => "bar is true").each do |discipline|
      discipline.bar_categories << Category.find_or_create_by_name("Clydesdale")
    end
    
    if ASSOCIATION.short_name == "obra"
      execute "delete from events where date >= '2010-01-01' and type like '%bar%'"
      OverallBar.calculate!
    end
  end

  def self.down
    Discipline.delete_all "name = 'Short Track'"
  end
end
