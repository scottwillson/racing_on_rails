#!/usr/bin/env ruby
# frozen_string_literal: true

# Show where beginner (Cat 5) and Novice categories score in each calculation before and after
# these Categories changes:
#   * "Beginner" is Cat 5, not 4. Beginner and Cat 5 are the same in road and cross.
#   * "Novice" stays Cat 5. Road uses it for Cat 5 (e.g. "Novice Women (Category 5 Ages 14 and Up)").
#   * Cat 4/5 fields are beginner fields, so they match Cat 5 when the calculation has one.
#
# Run after deploying those changes. "before" swaps the old behavior back in for comparison.
# Calculations::V3 parses category names on every calculate!, so calculations pick up the
# changes when they are recalculated.
#
# Beginner results need a Category 5 to land in. Without one, Beginner and Cat 5 results match
# nothing and are rejected, and Cat 4/5 results stay in Cat 4. So APPLY adds Category 5
# Men/Women to non-MTB BARs that have these results but no Category 5. Other calculations are
# reported but not changed.
#
# Reports only, changes nothing:
#   bin/rails runner script/beginner_category_report.rb
#
# Add the missing Category 5s, and update the ability_begin and ability_end columns stored on
# Beginner/Novice Category rows (used by the older Competitions code, not by Calculations):
#   APPLY=true bin/rails runner script/beginner_category_report.rb
#
# Options:
#   YEAR=2026        calculations to check (default: current year)
#   ALL=true         list unchanged matches too, not only the ones that move

APPLY = ENV["APPLY"] == "true"
YEAR = (ENV["YEAR"] || Time.zone.today.year).to_i
ALL = ENV["ALL"] == "true"

MTB_DISCIPLINES = ["Mountain Bike", "Downhill", "Super D", "Short Track"].freeze
CAT_5_NAMES = { "M" => "Category 5 Men", "F" => "Category 5 Women" }.freeze

NEW_CONSTANTS = {
  NAME_ABILITIES: Categories::Ability::NAME_ABILITIES,
  BEGINNER_ABILITIES: Categories::Ability::BEGINNER_ABILITIES
}.freeze

# No category has abilities -1..-1, so this turns off the Cat 4/5 => Cat 5 preference
OLD_CONSTANTS = {
  NAME_ABILITIES: Categories::Ability::NAME_ABILITIES.merge("Beginner" => 4, "Novice" => 5).freeze,
  BEGINNER_ABILITIES: (-1..-1)
}.freeze

def with_constants(constants)
  constants.each do |name, value|
    Categories::Ability.send(:remove_const, name)
    Categories::Ability.const_set(name, value)
  end
  yield
ensure
  NEW_CONSTANTS.each do |name, value|
    Categories::Ability.send(:remove_const, name)
    Categories::Ability.const_set(name, value)
  end
end

# Reproduce the matcher the calculator uses, without running a full calculation. Reload the
# calculation so its rules parse category names with the current constants.
def match(calculation_id, category_name)
  calculation = Calculations::V3::Calculation.find(calculation_id)
  model = Calculations::V3::Models::Category.new(category_name)
  match = if calculation.group_by == "age"
            model.best_match_by_age_in(calculation.rules.categories, nil)
          else
            model.best_match_in(calculation.rules.categories, nil)
          end
  match&.name || "(none: rejected)"
rescue StandardError => e
  "(error: #{e.message})"
end

# Cat 5 or Cat 4/5, not junior or masters. These belong in Category 5.
def beginner_field?(category)
  model = Calculations::V3::Models::Category.new(category.name)
  (model.abilities == (5..5) || model.beginner_abilities?) && !(model.age_group? && !model.senior?)
end

# Beginner, Novice, Cat 5 and Cat 4/5 categories raced in +year+, by discipline. Race discipline
# wins over event discipline, same as
# Calculations::V3::CalculationConcerns::SourceResults#race_discipline.
def categories_by_discipline(year)
  Race
    .joins(:event, :category)
    .includes(:discipline, :event, :category)
    .merge(Event.year(year))
    .where(
      "categories.name like ? or categories.name like ? or (categories.ability_begin in (4, 5) and categories.ability_end = 5)",
      "%Beginner%", "%Novice%"
    )
    .each_with_object(Hash.new { |hash, key| hash[key] = Set.new }) do |race, categories|
      categories[race.discipline&.name || race.event.discipline] << race.category
    end
end

by_discipline = categories_by_discipline(YEAR)

if by_discipline.empty?
  puts "No #{YEAR} races in Beginner, Novice, Cat 5 or Cat 4/5 categories."
  exit
end

puts "#{YEAR} Beginner, Novice, Cat 5 and Cat 4/5 categories by discipline:"
by_discipline.sort.each do |discipline, categories|
  puts "  #{discipline}: #{categories.map(&:name).sort.join(', ')}"
end
puts

calculations = Calculations::V3::Calculation
               .where(year: YEAR)
               .to_a
               .reject { |calculation| calculation.calculation_categories.empty? }
               .sort_by(&:name)

def categories_for(calculation, by_discipline)
  discipline_names = calculation.disciplines.map(&:name)
  if discipline_names.any?
    by_discipline.slice(*discipline_names).values.reduce(Set.new, :|)
  else
    by_discipline.values.reduce(Set.new, :|)
  end
end

moved = 0
affected = Set.new

calculations.each do |calculation|
  categories = categories_for(calculation, by_discipline)
  next if categories.empty?

  rows = categories.sort_by(&:name).filter_map do |category|
    before = with_constants(OLD_CONSTANTS) { match(calculation.id, category.name) }
    after = match(calculation.id, category.name)
    next if before == after && !ALL

    [category.name, before, after]
  end
  next if rows.empty?

  puts "#{calculation.name} (id #{calculation.id}, disciplines: #{calculation.disciplines.map(&:name).join(', ').presence || 'all'})"
  rows.each do |name, before, after|
    if before == after
      flag = "   "
    else
      flag = "-> "
      moved += 1
      affected << calculation
    end
    puts "  #{flag}#{name.ljust(34)} before: #{before.ljust(26)} after: #{after}"
  end
  puts
end

puts moved.zero? ? "No matches change." : "#{moved} matches change."
puts

# The Overall BAR (no disciplines) takes the discipline BARs' Category 5 results, so it gets
# Category 5 too. MTB categories are separate, so leave MTB BARs alone. Skip BARs grouped by
# age like the Age-Graded BAR: they have no ability categories. Only BARs: other
# calculations (series, cups) choose their own categories.
missing_cat_5 = Hash.new { |hash, key| hash[key] = Set.new }

calculations.select { |calculation| calculation.name.end_with?("BAR") && !calculation.team? && calculation.group_by != "age" }.each do |calculation|
  discipline_names = calculation.disciplines.map(&:name)
  next if (discipline_names & MTB_DISCIPLINES).any?

  existing = calculation.calculation_categories.map(&:name)
  categories_for(calculation, by_discipline.except(*MTB_DISCIPLINES)).select { |category| beginner_field?(category) }.each do |category|
    name = CAT_5_NAMES[category.women? ? "F" : "M"]
    missing_cat_5[calculation] << name unless existing.include?(name)
  end
end

if missing_cat_5.empty?
  puts "Every BAR with beginner results already has Category 5."
else
  puts "BARs missing Category 5 for beginner results:"
  missing_cat_5.each { |calculation, names| puts "  #{calculation.name} (id #{calculation.id}): #{names.to_a.sort.join(', ')}" }
end
puts

stale = Category.where("name like ? or name like ?", "%Beginner%", "%Novice%").select do |category|
  abilities = category.abilities_from_name
  category.ability_begin != abilities.first || category.ability_end != abilities.last
end

puts "#{stale.size} Category rows have stale ability_begin/ability_end."
puts

unless APPLY
  puts "Dry run. Re-run with APPLY=true to add the Category 5s above and update stale Category rows." if missing_cat_5.any? || stale.any?
  puts "Matches above don't have the missing Category 5s yet. Re-run this after APPLY to see where those results land." if missing_cat_5.any?
  exit
end

Calculations::V3::Calculation.transaction do
  missing_cat_5.each do |calculation, names|
    names.sort.each do |name|
      category = Category.find_or_create_by_normalized_name(name)
      calculation_category = calculation.calculation_categories.find_or_create_by!(category: category)
      puts "#{calculation.name}: added #{name} (calculations_categories #{calculation_category.id})"
    end
  end

  stale.each do |category|
    abilities = category.abilities_from_name
    category.update_columns ability_begin: abilities.first, ability_end: abilities.last
  end
  puts "Updated #{stale.size} Category rows." if stale.any?
end

puts
puts "Done. Recalculate the discipline calculations, then the Overall BAR last:"
(affected | missing_cat_5.keys).sort_by { |calculation| [calculation.disciplines.empty? ? 1 : 0, calculation.name] }.each do |calculation|
  puts "  Calculations::V3::Calculation.find(#{calculation.id}).calculate!  # #{calculation.name}"
end
