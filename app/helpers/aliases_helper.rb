module AliasesHelper
  def aka(person)
    if person && !person.aliases.empty?
      aliases = person.aliases.collect {|a| a.name}
      "(a.k.a. #{aliases.join(', ')})"
    end
  end
end