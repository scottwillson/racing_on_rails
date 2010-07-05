module AliasesHelper
  # Aliases as a commented list
  def aka(person)
    if person && person.aliases.any?
      aliases = person.aliases.collect(&:name)
      "(a.k.a. #{aliases.join(', ')})"
    end
  end
end
