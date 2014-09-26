module Events
  module Children
    extend ActiveSupport::Concern

    included do
      validate :parent_is_not_self

      belongs_to :parent, foreign_key: "parent_id", class_name: "Event"
      has_many :children,
               -> { order :date },
               class_name: "Event",
               foreign_key: "parent_id",
               dependent: :destroy,
               after_add: :children_changed,
               after_remove: :children_changed

      scope :child, lambda { where("parent_id is not null") }
      # :root?
      scope :not_child, lambda { where("parent_id is null") }

      scope :not_single_day_event, lambda {
        where "type is null or type != 'SingleDayEvent'"
      }
    end

    # Update child events from parents' attributes if child attribute has the
    # same value as the parent before update
    def update_children
      return true if new_record? || children.count == 0
      changes.select { |key, value| propogated_attributes.include?(key) }.each do |change|
        attribute = change.first
        was = change.last.first
        if was.blank?
          SingleDayEvent.where(
            "(#{attribute}=? or #{attribute} is null or #{attribute} = '') and parent_id=?", was, self[:id]
          ).update_all(attribute => self[attribute])
        else
          SingleDayEvent.where(attribute => was, parent_id: id).update_all(attribute => self[attribute])
        end
      end

      children.each(&:update_children)
      true
    end

    # Synch Races with children. More accurately: create a new Race on each child Event for each Race on the parent.
    def propagate_races
      # Do nothing in superclass
    end

    def children_changed(child)
      # Don't trigger callbacks
      Event.where(id: id).update_all(updated_at: Time.zone.now)
      true
    end

    # Always return false
    def missing_parent?
      false
    end

    def missing_children?
      missing_children.any?
    end

    # Always return empty Array
    def missing_children
      []
    end

    def multi_day_event_children_with_no_parent?
      multi_day_event_children_with_no_parent.any?
    end

    def multi_day_event_children_with_no_parent
      return [] unless name && date

      @multi_day_event_children_with_no_parent ||= SingleDayEvent.where(
          "parent_id is null and name = ? and extract(year from date) = ?
           and ((select count(*) from events where name = ? and extract(year from date) = ? and type in ('MultiDayEvent', 'Series', 'WeeklySeries')) = 0)",
           self.name, self.date.year, self.name, self.date.year)
      # Could do this in SQL
      if @multi_day_event_children_with_no_parent.size == 1
        @multi_day_event_children_with_no_parent = []
      end
      @multi_day_event_children_with_no_parent
    end

    def missing_parent
      nil
    end

    def parent_is_not_self
      if parent_id && parent_id == id
        errors.add("parent", "Event cannot be its own parent")
      end
    end

    def root_id
      root.try :id
    end
  end
end
