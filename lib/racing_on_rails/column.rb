module RacingOnRails
  class Column
  
    LEFT  = :left unless defined?(LEFT)
    RIGHT = :right unless defined?(RIGHT)
  
    attr_accessor :name, :description, :size, :justification, :fixed_size, :field, :link
  
    def initialize(name = '', description = nil, size = 0, fixed_size = false, justification = LEFT)
      @name = name
      set_field_from_name
      @description = description || name
      raise ArgumentError.new("size must be a number, but was '#{size}'") unless size.is_a?(Fixnum)
      @size = size
      raise ArgumentError.new("fixed_size must be a boolean, but was '#{fixed_size}'") unless fixed_size.is_a?(FalseClass) or fixed_size.is_a?(TrueClass)
      @fixed_size = fixed_size
      raise ArgumentError.new("justification must LEFT or RIGHT, but was '#{justification}") unless justification == LEFT or justification == RIGHT
      @justification = justification
    end
  
    def set_field_from_name
      unless name.blank?
        begin
          @field = @name.to_sym
        rescue ArgumentError => error
          raise ArgumentError.new("#{error}: Can't create column with name '#{@name}'")
        end
      end
    end
  
    def size=(value)
      unless fixed_size?
        @size = value
      end
    end
  
    def fixed_size?
      fixed_size
    end
  
    def to_s
      name
    end
  end
end