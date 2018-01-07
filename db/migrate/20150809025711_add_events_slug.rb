# frozen_string_literal: true

class AddEventsSlug < ActiveRecord::Migration
  def change
    SingleDayEvent.joins(:parent).where("parents_events.type = 'SingleDayEvent'").find_each do |event|
      event.update_column(:type, "Event")
    end

    Competitions::OregonCup.destroy(15_848) if Competitions::OregonCup.exists?(15_848)

    change_table :events do |t|
      t.string :slug, null: true, default: nil
      t.integer :year, null: false, default: nil
      t.index :slug
    end

    Event.find_each do |e|
      e.update_column :year, e.date.year
    end

    add_index :events, %i[year slug]
    add_index :events, :year

    Event.reset_column_information

    if Event.column_names.include?("slug")
      Event.transaction do
        Event
          .where("sanctioned_by is not null and sanctioned_by != '' and sanctioned_by != 'FIAC' and sanctioned_by != '0'")
          .find_each do |e|
          e.slug = nil
          e.set_slug
          say("#{e.id} #{e.date} #{e.name} #{e.slug}")
          e.save!
        end
      end
    end
  end
end
