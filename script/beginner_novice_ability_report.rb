#!/usr/bin/env ruby
# frozen_string_literal: true

# Show where Beginner and Novice categories score in each BAR before and after
# Categories::Ability changed "Beginner" from 4 to 5 (Beginner is Cat 5 in road and cross) and
# "Novice" from 5 to 3 (Novice is the MTB name for Cat 3).
#
# Run after deploying that change. "before" swaps the old values back in for comparison.
# Calculations::V3 parses category names on every calculate!, so BARs pick up the new values
# when they are recalculated. Nothing here changes BAR results.
#
# Reports only, changes nothing:
#   bin/rails runner script/beginner_novice_ability_report.rb
#
# Also update the ability_begin and ability_end columns stored on matching Category rows
# (used by the older Competitions code, not by the BARs):
#   APPLY=true bin/rails runner script/beginner_novice_ability_report.rb
#
# Options:
#   YEAR=2026        calculations to check (default: current year)
#   ALL=true         list unchanged matches too, not only the ones that move

APPLY = ENV["APPLY"] == "true"
YEAR = (ENV["YEAR"] || Time.zone.today.year).to_i
ALL = ENV["ALL"] == "true"

OLD_NAME_ABILITIES = Categories::Ability::NAME_ABILITIES.merge("Beginner" => 4, "Novice" => 5).freeze
NEW_NAME_ABILITIES = Categories::Ability::NAME_ABILITIES

def with_name_abilities(abilities)
  Categories::Ability.send(:remove_const, :NAME_ABILITIES)
  Categories::Ability.const_set(:NAME_ABILITIES, abilities)
  yield
ensure
  Categories::Ability.send(:remove_const, :NAME_ABILITIES)
  Categories::Ability.const_set(:NAME_ABILITIES, NEW_NAME_ABILITIES)
end

# Reproduce the matcher the calculator uses, without running a full calculation. Reload the
# calculation so its rules parse category names with the current abilities.
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

# Race discipline wins over event discipline, same as
# Calculations::V3::CalculationConcerns::SourceResults#race_discipline.
def categories_by_discipline(year)
  Race
    .joins(:event, :category)
    .includes(:discipline, :event, :category)
    .merge(Event.year(year))
    .where("categories.name like ? or categories.name like ?", "%Beginner%", "%Novice%")
    .each_with_object(Hash.new { |hash, key| hash[key] = Set.new }) do |race, categories|
      categories[race.discipline&.name || race.event.discipline] << race.category
    end
end

by_discipline = categories_by_discipline(YEAR)

if by_discipline.empty?
  puts "No #{YEAR} races in Beginner or Novice categories."
  exit
end

puts "#{YEAR} Beginner and Novice categories by discipline:"
by_discipline.sort.each do |discipline, categories|
  puts "  #{discipline}: #{categories.map(&:name).sort.join(', ')}"
end
puts

calculations = Calculations::V3::Calculation
               .where(year: YEAR)
               .to_a
               .reject { |calculation| calculation.calculation_categories.empty? }
               .sort_by(&:name)

moved = 0

calculations.each do |calculation|
  discipline_names = calculation.disciplines.map(&:name)
  categories = if discipline_names.any?
                 by_discipline.slice(*discipline_names).values.reduce(Set.new, :|)
               else
                 by_discipline.values.reduce(Set.new, :|)
               end
  next if categories.empty?

  rows = categories.sort_by(&:name).filter_map do |category|
    before = with_name_abilities(OLD_NAME_ABILITIES) { match(calculation.id, category.name) }
    after = match(calculation.id, category.name)
    next if before == after && !ALL

    [category.name, before, after]
  end
  next if rows.empty?

  puts "#{calculation.name} (id #{calculation.id}, disciplines: #{discipline_names.join(', ').presence || 'all'})"
  rows.each do |name, before, after|
    flag = before == after ? "   " : "-> "
    moved += 1 if before != after
    puts "  #{flag}#{name.ljust(34)} before: #{before.ljust(26)} after: #{after}"
  end
  puts
end

puts moved.zero? ? "No BAR matches change." : "#{moved} BAR matches change. Recalculate those BARs after deploying."
puts

stale = Category.where("name like ? or name like ?", "%Beginner%", "%Novice%").select do |category|
  abilities = category.abilities_from_name
  category.ability_begin != abilities.first || category.ability_end != abilities.last
end

puts "#{stale.size} Category rows have stale ability_begin/ability_end."
if stale.any? && !APPLY
  puts "Re-run with APPLY=true to update them."
  exit
end

stale.each do |category|
  abilities = category.abilities_from_name
  category.update_columns ability_begin: abilities.first, ability_end: abilities.last
end
puts "Updated #{stale.size} Category rows." if stale.any?
