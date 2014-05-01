module Grid
  # Used by Grid.
  #
  # Eventually wil be replaced by Tabular
  class Column

    LEFT  = :left unless defined?(LEFT)
    RIGHT = :right unless defined?(RIGHT)

    VALID_OPTIONS = [:name, :description, :size, :justification, :fixed_size] unless defined?(VALID_OPTIONS)

    attr_accessor :name, :description, :size, :justification, :fixed_size, :field, :link

    # Grid Column
    # === Options ===
    # * name
    # * description: defaults to +name+
    # * size: defaults to 0
    # * fixed_size: boolean, defaults to false
    # * justification: defaults to LEFT
    # * type: cast value to this Class
    def initialize(*options)
      if options
        options.flatten!
        options = options.first
      end
      options = {} if options.nil?

      options.keys.each do |option|
        raise ArgumentError.new("#{option} is not a valid option") unless VALID_OPTIONS.include?(option)
      end

      @name          = options[:name] || ''
      @description   = options[:description] || @name
      @size          = options[:size] || 0
      @fixed_size    = options[:fixed_size] || false
      @justification = options[:justification] || LEFT

      set_field_from_name
      raise ArgumentError.new("size must be a number, but was '#{@size}'") unless @size.is_a?(Fixnum)
      raise ArgumentError.new("fixed_size must be a boolean, but was '#{@fixed_size}'") unless @fixed_size.is_a?(FalseClass) or @fixed_size.is_a?(TrueClass)
      raise ArgumentError.new("justification must LEFT or RIGHT, but was '#{@justification}") unless @justification == LEFT or @justification == RIGHT
    end

    def set_field_from_name
      unless self.name.blank?
        begin
          self.field = self.name.strip.to_sym
        rescue ArgumentError => error
          raise ArgumentError.new("#{error}: Can't create column with name '#{self.name}'")
        end
      end
    end

    def field=(value)
      case value
      when Symbol
        @field = value
      when NilClass
        @field = nil
      else
        begin
          @field = value.to_sym
        rescue ArgumentError => error
          raise ArgumentError.new("#{error}: Can't create column with name '#{value}'")
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

    def valid?
      !@field.nil?
    end

    def present?
      name.present?
    end

    def to_s
      name
    end
  end
end
