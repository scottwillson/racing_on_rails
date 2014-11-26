module People
  module Authorization
    extend ActiveSupport::Concern

    included do
      has_and_belongs_to_many :editable_people, class_name: "Person", foreign_key: "editor_id", before_add: :validate_unique_editors
      has_and_belongs_to_many :editors, class_name: "Person", association_foreign_key: "editor_id", before_add: :validate_unique_editors
      has_many :editor_requests, dependent: :destroy
      has_many :sent_editor_requests, foreign_key: "editor_id", class_name: "EditorRequest", dependent: :destroy
      has_and_belongs_to_many :roles
    end

    def administrator?
      roles.any? { |role| role.name == "Administrator" }
    end

    def promoter?
      if new_record?
        false
      else
        Event.where(promoter_id: id).exists? || editable_events.present?
      end
    end

    def can_edit?(person)
      person == self || administrator? || person.editors.include?(self)
    end

    def validate_unique_editors(editor)
      if editors.include?(editor)
        raise ActiveRecord::ActiveRecordError, "Can't add duplicate editor #{editor.name} for #{name}"
      end

      if editor == self
        raise ActiveRecord::ActiveRecordError, "Can't be editor for self"
      end
    end

    def account_permissions
      (editors + editable_people).reject { |person| person == self }.uniq.map do |person|
        AccountPermission.new(person, editable_people.include?(person), editors.include?(person))
      end
    end
  end
end
