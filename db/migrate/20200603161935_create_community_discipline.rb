# frozen_string_literal: true

class CreateCommunityDiscipline < ActiveRecord::Migration[5.2]
  def up
    Discipline.find_by(name: "Community")&.destroy!
    Discipline.create!(name: "Community", bar: false)
  end

  def down
    Discipline.find_by(name: "Community")&.destroy!
  end
end
