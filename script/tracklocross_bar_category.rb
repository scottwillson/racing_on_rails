#!/usr/bin/env ruby
# frozen_string_literal: true

# Give Tracklocross its own category inside an existing BAR instead of letting it fall
# into the 1/2 BAR.
#
# Calculations::V3 routes a source result to a BAR category in
# Calculations::V3::Calculators::Categories#find_or_create_event_category, which defers to
# Categories::Matching#best_match_in. That matcher never looks at the category name as a
# label -- it only compares traits parsed out of the name: abilities, ages, equipment,
# gender, weight. "Tracklocross" is not a token any of those parsers recognize
# (Categories::Equipment only knows Singlespeed, Fix, the exact string "Track", and a short
# list of bike types), so "Tracklocross Men 1/2" parses trait-for-trait identically to
# "Category 1/2 Men" and gets absorbed by it.
#
# Listing the Tracklocross category among the calculation's own categories fixes this: both
# are still "equivalent", so best_match_in falls through to its exact_equivalent branch,
# which prefers the category whose name matches the source category exactly.
#
# Reports only, changes nothing:
#   bin/rails runner script/tracklocross_bar_category.rb
#
# Apply:
#   APPLY=true bin/rails runner script/tracklocross_bar_category.rb
#
# Options:
#   YEAR=2026                  calculations to change (default: current year)
#   PATTERN=%rackl%cross%      SQL LIKE used to find the source categories
#   MERGE_INTO="Tracklocross"  collapse every source category into one BAR category of this
#                              name using category mappings, instead of giving each source
#                              category its own BAR category
#   CALCULATION_IDS=1,2        only touch these calculations

APPLY = ENV["APPLY"] == "true"
YEAR = (ENV["YEAR"] || Time.zone.today.year).to_i
PATTERN = ENV["PATTERN"] || "%rackl%cross%"
MERGE_INTO = ENV["MERGE_INTO"].presence
CALCULATION_IDS = ENV["CALCULATION_IDS"].to_s.split(",").map(&:strip).compact_blank.map(&:to_i)

# Reproduce the matcher the calculator uses, without running a full calculation.
def current_match(calculation, category_name)
  model = Calculations::V3::Models::Category.new(category_name)
  if calculation.group_by == "age"
    model.best_match_by_age_in(calculation.rules.categories, nil)
  else
    model.best_match_in(calculation.rules.categories, nil)
  end
rescue StandardError => e
  Calculations::V3::Models::Category.new("(error: #{e.message})")
end

# Disciplines this category's races carry in +year+. Race discipline wins over event
# discipline, same as Calculations::V3::CalculationConcerns::SourceResults#race_discipline.
def disciplines_for(category, year)
  Race
    .joins(:event)
    .includes(:discipline, :event)
    .where(category_id: category.id)
    .merge(Event.year(year))
    .filter_map { |race| race.discipline&.name || race.event.discipline }
    .uniq
    .sort
end

source_categories = Category.where("name like ?", PATTERN).sort_by(&:name)

if source_categories.empty?
  puts "No categories match #{PATTERN}. Nothing to do."
  exit
end

puts "Source categories matching #{PATTERN}:"
source_categories.each do |category|
  disciplines = disciplines_for(category, YEAR)
  races = Race.where(category_id: category.id).count
  puts "  #{category.id} #{category.name.ljust(34)} races: #{races.to_s.ljust(5)} #{YEAR} disciplines: #{disciplines.join(', ')}"
end
puts

calculations = Calculations::V3::Calculation.where(year: YEAR)
calculations = calculations.where(id: CALCULATION_IDS) if CALCULATION_IDS.any?
calculations = calculations.to_a.reject { |calculation| calculation.calculation_categories.empty? }

affected = {}

calculations.sort_by(&:name).each do |calculation|
  matches = source_categories.filter_map do |source_category|
    match = current_match(calculation, source_category.name)
    [source_category, match] if match
  end
  next if matches.empty?

  affected[calculation] = matches.map(&:first)

  puts "#{calculation.name} (id #{calculation.id}, disciplines: #{calculation.disciplines.map(&:name).join(', ').presence || 'all'})"
  matches.each do |source_category, match|
    destination = MERGE_INTO || source_category.name
    puts "  #{source_category.name.ljust(34)} now scores in: #{match.name.ljust(28)} would become: #{destination}"
  end
  puts
end

if affected.empty?
  puts "No #{YEAR} calculation groups these categories anywhere. Nothing to change."
  exit
end

unless APPLY
  puts "Dry run. Re-run with APPLY=true to add the categories above."
  exit
end

# Mappings run before best_match_in and are unconditional, but they require a discipline:
# Models::Discipline#== returns false for nil, so a mapping with no discipline never fires.
# The unique index allows one mapping row per (calculation category, source category).
def create_mapping(calculation, calculation_category, source_category)
  names = disciplines_for(source_category, YEAR)
  names &= calculation.disciplines.map(&:name) if calculation.disciplines.any?
  discipline = names.filter_map { |discipline_name| Discipline[discipline_name] }.first

  if discipline.nil?
    puts "  SKIP mapping #{source_category.name}: no #{YEAR} discipline in #{calculation.name}"
    return
  end

  puts "  WARN #{source_category.name} spans #{names.join(', ')}; mapping only #{discipline.name}" if names.size > 1

  mapping = calculation_category.mappings.find_or_create_by!(category: source_category) do |new_mapping|
    new_mapping.discipline = discipline
  end
  puts "  mapping #{source_category.name} (#{discipline.name}) -> #{calculation_category.name} (#{mapping.id})"
end

Calculations::V3::Calculation.transaction do
  affected.each do |calculation, categories|
    bar_categories = MERGE_INTO ? [Category.find_or_create_by_normalized_name(MERGE_INTO)] : categories

    bar_categories.each do |bar_category|
      calculation_category = calculation.calculation_categories.find_or_create_by!(category: bar_category)
      puts "#{calculation.name}: BAR category #{bar_category.name} (calculations_categories #{calculation_category.id})"

      next unless MERGE_INTO

      categories.each { |source_category| create_mapping calculation, calculation_category, source_category }
    end
  end
end

puts
puts "Done. Recalculate the affected BARs to rebuild their races:"
affected.each_key { |calculation| puts "  Calculations::V3::Calculation.find(#{calculation.id}).calculate!" }
