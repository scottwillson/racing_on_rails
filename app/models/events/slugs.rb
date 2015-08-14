module Events
  module Slugs
    extend ActiveSupport::Concern

    included do
      validate :slug, unique: true, scope: :year

      def self.find_by_slug(slug)
        Event.where(slug: slug).current_year.first ||
        Event.where(slug: slug).order(:year).last
      end
    end
  end
end
