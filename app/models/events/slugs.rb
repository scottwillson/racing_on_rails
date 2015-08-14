module Events
  module Slugs
    extend ActiveSupport::Concern

    included do
      validate :slug, unique: true, scope: :year

      before_save :set_slug

      def self.find_by_slug(slug)
        Event.where(slug: slug).current_year.first ||
        Event.where(slug: slug).order(:year).last
      end
    end

    def set_slug
      if slug.blank?
        self.slug = create_slug
      end
    end

    def create_slug
      self.slug = full_name
                  .gsub(/20\d\d/, "")
                  .downcase
                  .gsub(/[^a-z0-9 ]/, "")
                  .underscore
                  .gsub(/ +/, " ")
                  .strip
                  .gsub(" ", "_")
    end
  end
end
