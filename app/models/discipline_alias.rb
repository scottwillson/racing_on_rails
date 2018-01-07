# frozen_string_literal: true

# Alternate names for Discipline
class DisciplineAlias < ActiveRecord::Base
  belongs_to :discipline
end
