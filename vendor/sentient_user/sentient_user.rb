# From https://github.com/bokmann/sentient_user
module SentientUser
  def self.included(base)
    base.class_eval {
      def self.current
        RequestLocals.fetch(:person) { nil }
      end

      def self.current=(o)
        raise(ArgumentError,
            "Expected an object of class '#{self}', got #{o.inspect}") unless (o.is_a?(self) || o.nil?)
        RequestLocals.store[:person] = o
      end

      def make_current
        RequestLocals.store[:person] = self
      end

      def current?
        RequestLocals.exist?(:person) && self.id == current.id
      end
    }
  end
end
