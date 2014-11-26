module Results
  module CustomAttributes
    extend ActiveSupport::Concern

    included do
      serialize :custom_attributes, Hash
      before_save :ensure_custom_attributes
    end

    def custom_attributes=(hash)
      if hash
        symbolized_hash = Hash.new
        hash.each { |key, value| symbolized_hash[key.to_s.to_sym] = value}
      end
      self[:custom_attributes] = symbolized_hash
    end

    def custom_attribute(sym)
      _sym = sym.to_sym
      if custom_attributes && custom_attributes.has_key?(_sym)
        custom_attributes[_sym]
      elsif race && race.custom_columns && race.custom_columns.include?(_sym)
        nil
      else
        raise NoMethodError, "No custom attribute '#{sym}' for race"
      end
    end

    def ensure_custom_attributes
      if race_id && race.custom_columns && !custom_attributes
        self.custom_attributes = Hash.new
        race.custom_columns.each do |key|
          custom_attributes[key.to_sym] = nil
        end
      end
      true
    end
  end
end
