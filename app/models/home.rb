# frozen_string_literal: true

class Home < ApplicationRecord
  belongs_to :photo, optional: true

  def self.current
    Home.first || Home.create!
  end
end
