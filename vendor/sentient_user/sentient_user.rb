# From https://github.com/bokmann/sentient_user
module SentientUser
  def self.included(base)
    base.class_eval {
      def self.current
        Thread.current[:person]
      end

      def self.current=(o)
        raise(ArgumentError,
            "Expected an object of class '#{self}', got #{o.inspect}") unless (o.is_a?(self) || o.nil?)
        Thread.current[:person] = o
      end

      def make_current
        Thread.current[:person] = self
      end

      def current?
        !Thread.current[:person].nil? && self.id == Thread.current[:person].id
      end

      def self.do_as(person, &block)
        old_person = self.current

        begin
          self.current = person
          response = block.call unless block.nil?
        ensure
          self.current = old_person
        end

        response
      end
    }
  end
end
