module Events
  # Editors, too. Should just be has_many :promoters
  module Promoters
    extend ActiveSupport::Concern

    included do
      attr_reader :new_promoter_name
      attr_reader :new_team_name

      before_save :set_promoter

      belongs_to :promoter, class_name: "Person"
      has_and_belongs_to_many :editors, class_name: "Person", association_foreign_key: "editor_id", join_table: "editors_events"

      scope :editable_by, lambda { |person|
        if person.nil?
          where("true = false")
        elsif person.administrator?
          # No scope
        else
          joins("left outer join editors_events on event_id = events.id").
          where("promoter_id = :person_id or editors_events.editor_id = :person_id", person_id: person)
        end
      }
    end

    def promoter_name
      promoter.name if promoter
    end

    def promoter_name=(value)
      @new_promoter_name = value
    end

    def set_promoter
      if new_promoter_name.present?
        promoters = Person.find_all_by_name_or_alias(new_promoter_name)
        case promoters.size
        when 0
          self.promoter = Person.create!(name: new_promoter_name)
        when 1
          self.promoter = promoters.first
        else
          self.promoter = promoters.detect { |promoter| promoter.id == promoter_id } || promoters.first
        end
      elsif new_promoter_name == ""
        self.promoter = nil
      end
    end

    # Find valid email—either promoter's email or event email. If all are blank, raise exception.
    def email!
      if promoter.try(:email).present?
        promoter.email
      elsif email.present?
        email
      else
        raise BlankEmail, "Event #{name} has no email"
      end
    end

    class BlankEmail < StandardError; end
  end
end
