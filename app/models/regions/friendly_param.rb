# frozen_string_literal: true

module Regions
  module FriendlyParam
    extend ActiveSupport::Concern

    def to_param
      name&.downcase&.gsub(/\W/, " ")&.strip&.gsub(/  +/, " ")&.tr(" ", "-")
    end
  end
end
