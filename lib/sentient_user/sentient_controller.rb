module SentientController
  def self.included(base)
    base.class_eval {
      before_filter do |c|
        Person.current = c.send(:current_person)
      end
    }
  end
end