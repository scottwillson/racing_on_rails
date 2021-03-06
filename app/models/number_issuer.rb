# frozen_string_literal: true

# Any 'party' that issues a set of numbers. Usually, this is the racing Association,
# but large events like stage races have their own set of numbers, as do
# series like the Cross Crusade
class NumberIssuer < ApplicationRecord
  validates :name, presence: true

  has_many :race_numbers

  def association?
    name == RacingAssociation.current.short_name
  end

  def to_s
    "#<NumberIssuer #{name}>"
  end
end
