# frozen_string_literal: true

module People
  module Names
    extend ActiveSupport::Concern

    included do
      # Does not consider Aliases
      def self.find_all_by_name(name)
        Person.where(name: name).order("last_name, first_name")
      end

      # "Jane Doe" or "Jane", "Doe" or name: "Jane Doe" or first_name: "Jane", last_name: "Doe"
      def self.find_all_by_name_or_alias(*args)
        options = args.extract_options!
        options.each_key { |key| raise(ArgumentError, "'#{key}' is not a valid key") unless %i[name first_name last_name].include?(key) }

        name = args.join(" ") if options.empty?

        name ||= options[:name]
        first_name = options[:first_name]
        last_name = options[:last_name]

        if name.present?
          Person.where(name: name) | Alias.find_all_people_by_name(name)
        elsif first_name.present? && last_name.blank?
          Person.where(first_name: first_name) | Alias.find_all_people_by_name(Person.full_name(first_name, last_name))
        elsif first_name.blank? && last_name.present?
          Person.where(last_name: last_name) | Alias.find_all_people_by_name(Person.full_name(first_name, last_name))
        else
          Person.where(first_name: first_name).where(last_name: last_name) | Alias.find_all_people_by_name(Person.full_name(first_name, last_name))
        end
      end

      # Considers aliases
      def self.name_like(name)
        return Person.none if name.blank?

        name_like = "%#{name.strip}%"
        Person
          .where("people.name like ? or aliases.name like ?", name_like, name_like)
          .includes(:team)
          .includes(:aliases)
          .references(:aliases)
          .order("last_name, first_name")
      end

      def self.find_by_name(name)
        Person.where(name: name).first
      end

      def self.full_name(first_name, last_name)
        "#{first_name} #{last_name}".strip
      end
    end

    def split_name(value)
      if value.include?(",")
        split_name_by(value, ",").reverse
      else
        split_name_by value, " "
      end
    end

    def split_name_by(value, delimiter)
      parts = value
              .split(delimiter)
              .map(&:strip)
              .compact

      case parts.size
      when 0
        ["", ""]
      when 1
        [parts.first, ""]
      else
        [parts.first, parts[1..(parts.size - 1)].join(" ")]
      end
    end

    def all_other_people_with_same_name
      if name.present?
        people = Person.find_all_by_name(name) | Alias.find_all_people_by_name(name)
        people.reject { |person| person == self }
      else
        Person.none
      end
    end

    def people_name_sounds_like
      return [] if name.blank?

      Person.where.not(id: id).where("soundex(name) = soundex(?)", name.strip) +
        Person.where(first_name: last_name).where(last_name: first_name)
    end

    # Name on year. Could be rolled into Nameable?
    def name(date_or_year = nil)
      year = parse_year(date_or_year)
      name_record_for_year(year).try(:name) || Person.full_name(first_name(year), last_name(year))
    end

    def first_name(date_or_year = nil)
      year = parse_year(date_or_year)
      name_record_for_year(year).try(:first_name) || self[:first_name]
    end

    def last_name(date_or_year = nil)
      year = parse_year(date_or_year)
      name_record_for_year(year).try(:last_name) || self[:last_name]
    end

    def email_with_name
      if name.present?
        "#{name} <#{email}>"
      else
        email
      end
    end

    def name_or_login
      name.presence || login.presence || email
    end

    def last_name_or_login
      last_name.presence || login.presence || email
    end

    # Name. If +name+ is blank, returns email and phone
    def name_or_contact_info
      name.presence || [email, home_phone].join(", ")
    end

    # Tries to split +name+ into +first_name+ and +last_name+
    # TODO Handle name, Jr.
    def name=(value)
      self[:name] = value
      if value.blank?
        set_name_blank
        return
      end

      self[:first_name], self[:last_name] = split_name(value)
      name
    end

    def set_name_blank
      self[:first_name] = ""
      self[:last_name] = ""
      name
    end

    def first_name=(value)
      self[:name] = Person.full_name(value, last_name).try :strip
      self[:first_name] = value.try :strip
    end

    def last_name=(value)
      self[:name] = Person.full_name(first_name, value).try :strip
      self[:last_name] = value.try :strip
    end
  end
end
