#!/usr/bin/env ruby

def move_to_parent(parent, child)
  if parent && child && parent != child && child.parent != parent
    Category.logger.debug "#{parent.name} => #{child.name}"

    if child.descendants.include?(parent)
      puts "#{parent.name} is a descendant of #{child.name}"
      return false
    end

    if parent.ancestors.include?(child)
      puts "#{child.name} is an ancestor of #{parent.name}"
      return false
    end

    parent.children << child
  end
end

Category.transaction do
  puts "Group categories"
  {
    "Beginner 12-1" => "Beginner 12-14",
    "C'Ategory 1/2" => "Category 1/2",
    "Junior M" => "Junior Men",
    "Junior Men Non Uci" => "Junior Men Non-UCI",
    "Pro/Cat 1" => "Pro/Category 1",
    "-14" => "U14",
    "Sram" => "SRAM",
    "Category 3 Junior Women 18u" => "Junior Women Category 3"

  }.each do |old_name, new_name|
    old_category = Category.where(name: old_name).first
    if old_category
      new_category = Category.find_or_create_by(name: new_name)
      new_category.raw_name = new_name
      new_category.save!
      unless old_category == new_category
        old_category.replace_with new_category.reload
      end
    end
  end

  [ "Men", "Women" ].each do |gender|
    (1..2).each do |category|
      parent = Category.where(name: "Senior #{gender}").first
      age_parent = Category.where(name: "Category #{category} #{gender}").first
      parent.children(true).select { |c| c.name[%r{\bCategory #{category}\b}]}.each do |child|
        move_to_parent age_parent, child
      end
    end
  end

  [ "Men", "Women" ].each do |gender|
    cat_4 = Category.where(name: "Category 4 #{gender}").first
    cat_3 = Category.where(name: "Category 3 #{gender}").first
    cat_4.children(true).select { |c| c.name[%r{Category 3 }]}.each do |child|
      move_to_parent cat_3, child
    end
  end

  [ "Men", "Women" ].each do |gender|
    cat_2 = Category.where(name: "Category 2 #{gender}").first
    cat_1 = Category.where(name: "Category 1 #{gender}").first
    cat_2.descendants.select { |c| c.name[%r{1/2/3}]}.each do |child|
      move_to_parent cat_1, child
    end
  end
 parent = Category.where(name: "Category 4/5 Men").first
  [ 5, 4 ].each do |number|
    age_parent = Category.where(name: "Category #{number} Men").first
    parent.children(true).select { |c| c.name[/\b#{number}\b/]}.each do |child|
      move_to_parent age_parent, child
    end
  end

  parent = Category.where(name: "Masters Men").first
  [ 30, 35, 40, 45, 50, 55, 60, 65 ].each do |age|
    age_parent = Category.where(name: "Masters Men #{age}-#{age + 4}").first
    (age..(age + 4)).each do |child_age|
      parent.children(true).select { |c| c.name[/#{child_age}/]}.each do |child|
        move_to_parent age_parent, child
      end
    end
  end

  age_parent = Category.where(name: "Masters Men 70+").first
  (70..99).each do |child_age|
    parent.children(true).select { |c| c.name[/#{child_age}/]}.each do |child|
      move_to_parent age_parent, child
    end
  end

  parent = Category.where(name: "Masters Women").first
  [ 30, 35, 40, 45, 50, 55 ].each do |age|
    age_parent = Category.where(name: "Masters Women #{age}-#{age + 4}").first
    (age..(age + 4)).each do |child_age|
      parent.children(true).select { |c| c.name[/#{child_age}/]}.each do |child|
        move_to_parent age_parent, child
      end
    end
  end

  age_parent = Category.where(name: "Masters Women 60+").first
  (60..99).each do |child_age|
    parent.children(true).select { |c| c.name[/#{child_age}/]}.each do |child|
      move_to_parent age_parent, child
    end
  end

  [ "Men", "Women" ].each do |gender|
    parent = Category.where(name: "Junior #{gender}").first
    [ [10, 12], [13, 14], [15, 16], [17, 18] ].each do |start_age, end_age|
      age_parent = Category.where(name: "Junior #{gender} #{start_age}-#{end_age}").first
      (start_age..end_age).each do |child_age|
        parent.children(true).select { |c| c.name[/#{child_age}/]}.each do |child|
          move_to_parent age_parent, child
        end
      end
    end
  end

  parent = Category.where(name: "Category 4/5 Men").first
  [ [ "Beginner Men", "Beginner" ] ].each do |age_parent_name, child_name|
    age_parent = Category.where(name: age_parent_name).first
    parent.children(true).select { |c| c.name[/\b#{child_name}\b/]}.each do |child|
      move_to_parent age_parent, child
    end
  end

  parent = Category.where(name: "Category 4/5 Men").first
  [ [ "Category 5 Men", "Beginner" ],
    [ "Category 4 Men", "C" ],
    [ "Category 4 Men", "Novice" ] ].each do |age_parent_name, child_name|
    age_parent = Category.where(name: age_parent_name).first
    parent.children(true).select { |c| c.name[/\b#{child_name}\b/]}.each do |child|
      move_to_parent age_parent, child
    end
  end

  parent = Category.where(name: "Category 4 Women").first
  [ [ "Beginner Women", "Beginner" ] ].each do |age_parent_name, child_name|
    age_parent = Category.where(name: age_parent_name).first
    parent.children(true).select { |c| c.name[/\b#{child_name}\b/]}.each do |child|
      move_to_parent age_parent, child
    end
  end

  parent = Category.where(name: "Category 4 Women").first
  [ [ "Category 5 Women", "Beginner" ],
    [ "Category 4 Women", "C" ],
    [ "Category 4 Women", "Novice" ] ].each do |age_parent_name, child_name|
    age_parent = Category.where(name: age_parent_name).first
    parent.children(true).select { |c| c.name[/\b#{child_name}\b/]}.each do |child|
      move_to_parent age_parent, child
    end
  end

  parent = Category.where(name: "Category 3 Men").first
  [ [ "Sport Men 19-39", "Sport" ] ].each do |age_parent_name, child_name|
    age_parent = Category.where(name: age_parent_name).first
    parent.children(true).select { |c| c.name[/\b#{child_name}\b/]}.each do |child|
      move_to_parent age_parent, child
    end
  end

  parent = Category.where(name: "Category 3 Women").first
  [ [ "Sport Women 19-39", "Sport" ] ].each do |age_parent_name, child_name|
    age_parent = Category.where(name: age_parent_name).first
    parent.children(true).select { |c| c.name[/\b#{child_name}\b/]}.each do |child|
      move_to_parent age_parent, child
    end
  end

  parent = Category.where(name: "Senior Men").first
  [ [ "Expert Men 19-39", "Expert" ], [ "Elite Men", "Elite" ], [ "Elite Men", "Semi-Pro" ] ].each do |age_parent_name, child_name|
    age_parent = Category.where(name: age_parent_name).first
    parent.children(true).select { |c| c.name[/\b#{child_name}\b/]}.each do |child|
      move_to_parent age_parent, child
    end
  end

  parent = Category.where(name: "Senior Women").first
  [ [ "Expert Women 19-39", "Expert" ], [ "Elite Women", "Elite" ], [ "Elite Women", "Semi-Pro" ] ].each do |age_parent_name, child_name|
    age_parent = Category.where(name: age_parent_name).first
    parent.children(true).select { |c| c.name[/\b#{child_name}\b/]}.each do |child|
      move_to_parent age_parent, child
    end
  end

  [ "Men", "Women" ].each do |gender|
    parent = Category.where(name: "Category 3 #{gender}").first
    [ "3/4/5", "3/4" ].each do |categories|
      age_parent = Category.where(name: "Category #{categories} #{gender}").first
      parent.children(true).select { |c| c.name[%r{\b#{categories}\b}]}.each do |child|
        move_to_parent age_parent, child
      end
    end
  end

  [ "Men", "Women" ].each do |gender|
    parent = Category.where(name: "Senior #{gender}").first
    [ "1/2/3/4", "Pro/1/2/3", "2/3/4", "Pro/1/2", "1/2/3", "2/3", "1/2" ].each do |categories|
      age_parent = Category.where(name: "Category #{categories} #{gender}").first
      parent.children(true).select { |c| c.name[%r{\b#{categories}\b}]}.each do |child|
        move_to_parent age_parent, child
      end
    end
  end


  {
    "(Beginner) Category 3 Men 19-34" => "Category 3 Men",
    "(Sport) Category 2 Men 19-34" => "Category 2 Men",
    "Beginner Men (Open)[Category 3] (Saturday Only)" => "Category 3 Men",
    "Beginner Men (Open)[Category 3]" => "Category 3 Men",
    "Category - 4/5" => "Category 4/5 Men",
    "Category 1 Men 19-34" => "Category 1 Men",
    "Category 1/Category 2 Women (U34)" => "Category 1 Women",
    "Category 1/Category 2 Women (U35)" => "Category 1 Women",
    "Category 1/Category 2 Women U35" => "Category 1 Women",
    "Category 1/Pro 19-39 Men" => "Category 1 Men",
    "Category 1/Pro 19-39 Women" => "Category 1 Women",
    "Category 1/Pro 19-39" => "Category 1 Men",
    "Category 1/Pro Men" => "Category 1 Men",
    "Category 1/Pro Women 19-39" => "Category 1 Women",
    "Category 1/Pro Women" => "Category 1 Women",
    "Category 1/Pro" => "Category 1 Men",
    "Category 2 (Sport) 19-34 Men" => "Category 2 Men",
    "Category 2 19-29" => "Category 2 Men",
    "Category 2 19-34 Men (9)" => "Category 2 Men",
    "Category 2 19-34 Men" => "Category 2 Men",
    "Category 2 19-34" => "Category 2 Men",
    "Category 2 19-39 Men" => "Category 2 Men",
    "Category 2 and 3 Men" => "Category 2 Men",
    "Category 2 Hardtail" => "Category 2 Men",
    "Category 2 Men (19-29)" => "Category 2 Men",
    "Category 2 Men (19-39)" => "Category 2 Men",
    "Category 2 Men (30-39)" => "Category 2 Men",
    "Category 2 Men (Sport)" => "Category 2 Men",
    "Category 2 Men 19-24" => "Category 2 Men",
    "Category 2 Men 19-29" => "Category 2 Men",
    "Category 2 Men 19-34" => "Category 2 Men",
    "Category 2 Men 19-34" => "Category 2 Men",
    "Category 2 Men 19-39" => "Category 2 Men",
    "Category 2 Men 25-29" => "Category 2 Men",
    "Category 2 Men 30-39" => "Category 2 Men",
    "Category 2 Men Hardtail" => "Category 2 Men",
    "Category 2 Men Open" => "Category 2 Men",
    "Category 2 Men U34" => "Category 2 Men",
    "Category 2 Men U35" => "Category 2 Men",
    "Category 2 Men" => "Category 2 Men",
    "Category 2 Senior Men 19-39" => "Category 2 Men",
    "Category 2 Senior Men" => "Category 2 Men",
    "Category 2 Women U34" => "Category 2 Women",
    "Category 2" => "Category 2 Men",
    "Category 2/19-39" => "Category 2 Men",
    "Category 2/3 19-39 Women" => "Category 2 Women",
    "Category 2/3 19-39" => "Category 2 Men",
    "Category 2/3 Men 19-35" => "Category 2 Men",
    "Category 2/3 Men" => "Category 2 Men",
    "Category 2/30-39" => "Category 2 Men",
    "Category 3 (Beginner) 19-34 Men" => "Category 3 Men",
    "Category 3 (Beginner) Men" => "Category 3 Men",
    "Category 3 19-34 Men (17)" => "Category 3 Men",
    "Category 3 19-34 Men" => "Category 3 Men",
    "Category 3 19-34" => "Category 3 Men",
    "Category 3 19-39 Men" => "Category 3 Men",
    "Category 3 Beginner Men" => "Category 3 Men",
    "Category 3 Beginner Women" => "Category 3 Women",
    "Category 3 Men 19+" => "Category 3 Men",
    "Category 3 Men 19-29" => "Category 3 Men",
    "Category 3 Men 19-34 Men" => "Category 3 Men",
    "Category 3 Men 19-34" => "Category 3 Men",
    "Category 3 Men 19-39 Men" => "Category 3 Men",
    "Category 3 Men 19-39" => "Category 3 Men",
    "Category 3 Men 19-44" => "Category 3 Men",
    "Category 3 Senior Men 19-39" => "Category 3 Men",
    "Category 3 Women 19+" => "Category 3 Women",
    "Category 3 Women 19-39 25" => "Category 3 Women",
    "Category 4/5 and Beginner" => "Category 4/5 Men",
    "Category 4/5 Final" => "Category 4/5 Men",
    "Category 4/5 Finish Sprint" => "Category 4/5 Men",
    "Category 4/5 Junior" => "Category 4/5 Men",
    "Category 4/5 Men 3K" => "Category 4/5 Men",
    "Category 4/5 Men Kilo" => "Category 4/5 Men",
    "Category 4/5 Men Sprint" => "Category 4/5 Men",
    "Category 4/5 Men Sprints" => "Category 4/5 Men",
    "Category 4/5 Men" => "Category 4 Men",
    "Category 4/5 Points Race" => "Category 4/5 Men",
    "Category 4/5 Points Sprint" => "Category 4/5 Men",
    "Category 4/5 Race" => "Category 4/5 Men",
    "Category 4/5 Sprints A" => "Category 4/5 Men",
    "Category 4/5 Sprints B" => "Category 4/5 Men",
    "Category 4/5" => "Category 4/5 Men",
    "Category 4/5+" => "Category 4/5 Men",
    "Category 4/5, Omnium" => "Category 4/5 Men",
    "Category Men 4/5" => "Category 4/5 Men",
    "Elite/Category 1 Men" => "Elite Men",
    "Elite/Category 1 Women" => "Category 1 Women",
    "Expert (19-39)[Category 1]" => "Category 1 Men",
    "Expert (Category 1) Men 19-44" => "Category 1 Men",
    "Expert (Category 1) Men 19-44" => "Category 1 Men",
    "Expert (Category 1) Men" => "Category 1 Men",
    "Expert (Category 1) Women" => "Category 1 Women",
    "Expert (Category 1) Women" => "Category 1 Women",
    "Expert - Saturday Women Category 4 Omnium" => "Category 1 Women",
    "Expert 19-39 Men" => "Category 1 Men",
    "Expert 19-39" => "Category 1 Men",
    "Expert Men 13-39" => "Category 1 Men",
    "Expert Men 19-24" => "Category 1 Men",
    "Expert Men 19-29" => "Category 1 Men",
    "Expert Men 19-39" => "Category 1 Men",
    "Expert Men 25-29" => "Category 1 Men",
    "Expert Men U34" => "Category 1 Men",
    "Expert Men" => "Category 1 Men",
    "Expert Open Men" => "Category 1 Men",
    "Expert Women (Category 1)" => "Category 1 Women",
    "Expert Women (Open)[Category 1]" => "Category 1 Women",
    "Expert Women 19-39" => "Category 1 Women",
    "Expert/Pro Men" => "Pro Men",
    "Men 1, 2" => "Category 1 Men",
    "Men 19-24 Category 1" => "Category 1 Men",
    "Men 19-29 Category 2" => "Category 2 Men",
    "Men 19-29 Category 3" => "Category 3 Men",
    "Men 2" => "Category 2 Men",
    "Men 25-29 Category 1" => "Category 1 Men",
    "Men 30-34 Category 1" => "Category 1 Men",
    "Men 4/5 Finish Order" => "Category 4/5 Men",
    "Men 4/5 Mid-race Sprint" => "Category 4/5 Men",
    "Men 4/5 Omnium" => "Category 4/5 Men",
    "Men 4/5 Overall" => "Category 4/5 Men",
    "Men 4/5" => "Category 4/5 Men",
    "Men Category 1 (15-18)" => "Category 1 Men",
    "Men Category 1 (19-34)" => "Category 1 Men",
    "Men Category 1 19-34" => "Category 1 Men",
    "Men Category 1 19-34m" => "Category 1 Men",
    "Men Category 1 19-39" => "Category 1 Men",
    "Men Category 1" => "Category 1 Men",
    "Men Category 1-3" => "Category 1 Men",
    "Men Category 1/2" => "Category 1 Men",
    "Men Category 1/2/3" => "Category 1 Men",
    "Men Category 1/3" => "Category 1 Men",
    "Men Category 2 19-24" => "Category 2 Men",
    "Men Category 2 19-34" => "Category 2 Men",
    "Men Category 2 19-39" => "Category 2 Men",
    "Men Category 2 19-39" => "Category 2 Men",
    "Men Category 2" => "Category 2 Men",
    "Men Category 2/3 19-34" => "Category 2 Men",
    "Men Category 2/3" => "Category 2 Men",
    "Men Category 3 (19-34)" => "Category 3 Men",
    "Men Category 3 19-34" => "Category 3 Men",
    "Men Category 4/5 (Racing Age 18 Or U)" => "Category 4/5 Men",
    "Men Category 4/5 3K" => "Category 4/5 Men",
    "Men Category 4/5" => "Category 4/5 Men",
    "Men Pro" => "Pro Men",
    "Men Pro/1" => "Pro Men",
    "Men Pro/Category 1 U35" => "Pro Men",
    "Men Qualifier For Mass Start Events; Category 2-4 Only (Fri)" => "Category 2 Men",
    "MTB Category 1/Pro Men 19-39" => "Category 1 Men",
    "MTB Category 1/Pro Women 19-39" => "Category 1 Women",
    "MTB Category 2 Men 19-39" => "Category 2 Men",
    "MTB Category 2 Men 19-39" => "Category 2 Men",
    "MTB Category 2 Women 19-39" => "Category 2 Women",
    "MTB Category 3 Men 19-39" => "Category 3 Men",
    "MTB Category 3 Women 19-39" => "Category 3 Women",
    "Novice (Category 3) Men 19-39" => "Category 3 Men",
    "Novice (Category 3) Women 19-39" => "Category 3 Women",
    "Novice Women" => "Category 3 Women",
    "Open 4/5" => "Category 4/5 Men",
    "Pro 1 Men" => "Pro Men",
    "Pro 1, 2" => "Pro Men",
    "Pro 1-3 Women" => "Category 1 Women",
    "Pro 12-4" => "Pro Men",
    "Pro Men (1)" => "Pro Men",
    "Pro Men (Open)" => "Pro Men",
    "Pro Men Open" => "Pro Men",
    "Pro Men" => "Pro Men",
    "Pro Women (5)" => "Category 1 Women",
    "Pro Women (Open)" => "Category 1 Women",
    "Pro Women 1-3" => "Category 1 Women",
    "Pro" => "Pro Men",
    "Pro-Category 1 Women" => "Pro Women",
    "Pro/1 Men 19-39" => "Pro Men",
    "Pro/1 Men" => "Pro Men",
    "Pro/1 Women 19-39" => "Category 1 Women",
    "Pro/1 Women" => "Category 1 Women",
    "Pro/Category 1 Men 19-34" => "Pro Men",
    "Pro/Category 1 Men" => "Pro Men",
    "Pro/Exp Two-Person Mixed 12-17" => "Category 1 Women",
    "Pro/Expert Two-Person Men" => "Pro Men",
    "Pro/Expert" => "Pro Men",
    "Pro/Exprert Women" => "Category 1 Women",
    "Pro/Semi-pro Men" => "Pro Men",
    "Pro/Semi-Pro/Expert Men" => "Pro Men",
    "Road Category 2/3 Men 19-39" => "Category 2 Men",
    "Road Category 4/5 Men 19-39" => "Category 4/5 Men",
    "Sen Men 4/5" => "Category 4/5 Men",
    "Senior Men (3)" => "Category 3 Men",
    "Senior Men (4/5)" => "Category 4/5 Men",
    "Senior Men (Category 1/2/3)" => "Category 1 Men",
    "Senior Men 4/5" => "Category 4/5 Men",
    "Senior Men Category 1/2" => "Category 1 Men",
    "Senior Men Category 1/2/3" => "Category 1 Men",
    "Senior Men Category 4/5" => "Category 4/5 Men",
    "Sport (Category 2) Men 19-39" => "Category 2 Men",
    "Sport (Category 2) Men 19-39" => "Category 2 Men",
    "Sport (Category 2) Women 19-39" => "Category 2 Women",
    "Sport (Category 2/3) Men 19-39" => "Category 2 Men",
    "Sport Men (19-39)[Category 2]" => "Category 2 Men",
    "Sport Men (19-39)[Category 2]" => "Category 2 Men",
    "Sport Men 19-39" => "Category 2 Men",
    "Sport Women 19-39" => "Category 2 Women",
    "Woman Pro" => "Category 1 Women",
    "Women 1-3" => "Category 1 Women",
    "Women 2" => "Category 2 Women",
    "Women Category 2 19-39" => "Category 2 Women",
    "Women Pro 1-3" => "Category 1 Women",
    "Women Pro/Category 1" => "Category 1 Women"
  }.each do |child_name, parent_name|
    parent = Category.where(name: parent_name).first
    child = Category.where(name: child_name).first
    move_to_parent parent, child
  end

  puts "Update results' cached race names"
  result_count = Result.count
  index = 0
  Result.includes(race: :category).find_each do |result|
    if result.race_name != result.race.try(:name)
      result.update_column :race_name, result.race.try(:name)
    end

    index = index + 1
    if index % 100 == 0
      putc "."
    end
    if index % 10000 == 0
      puts "#{index}/#{result_count}"
    end
  end
  puts

  raise(ActiveRecord::Rollback) unless ENV["DOIT"].present?
end

puts "Recalculate BAR"
mtb_bar = Competitions::Bar.current_year.where(discipline: "Mountain Bike").first
mtb_bar.destroy_races
Competitions::Bar.calculate!

# Map to highest category. Example: cat 3/4/5 goes in cat 3
# cat in cat, even if "expert" "sport", etc.
# overall bar will map MTB categories
# if "expert, sport, etc." put in MTB numberic category (example)
# beginers should always be under category 5
# Novice: cat 3 if MTB; otherwise Cat 5
# Juniors go in the highest age bracket. Example: Junior Men 12-18 goes in Junior Men 17-18
# Masters go in the lowest age bracket. Example: Masters Men 30-39 goes in Masters 30-34.


true
