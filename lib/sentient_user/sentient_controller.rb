module SentientController
  def self.included(base)
    base.class_eval {
      before_filter do |controller|
        Person.current = controller.send(:current_person)
      end
    }
  end
end