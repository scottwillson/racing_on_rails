# frozen_string_literal: true

module AliasesHelper
  # Aliases as a commented list
  def aka(person)
    if person&.aliases&.any?
      aliases = person.aliases.collect(&:name)
      "(a.k.a. #{aliases.join(', ')})"
    end
  end
end
