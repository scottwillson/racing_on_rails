#!/usr/bin/env ruby
# frozen_string_literal: true

::Category.order(:name).all.each do |category|
  category.set_abilities_from_name
  category.set_ages_from_name
  category.set_equipment_from_name
  category.set_gender_from_name
  category.set_weight_from_name

  if category.changed?
    puts "#{category.name} #{category.changes}"
  end

  category.save!
end.size
