module AliasesHelper
  def aka(racer)
    if racer && !racer.aliases.empty?
      aliases = racer.aliases.collect {|a| a.name}
      "(a.k.a. #{aliases.join(', ')})"
    end
  end
end