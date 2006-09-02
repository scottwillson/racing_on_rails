module RacingOnRails
  class Association

    attr_accessor :name, :short_name
    
    def initialize
      @name = 'Bicycle Racing Association'
      @short_name = 'BRA'
    end
  end
end