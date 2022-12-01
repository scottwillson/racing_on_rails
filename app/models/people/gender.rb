# frozen_string_literal: true

module People
  module Gender
    extend ActiveSupport::Concern

    def female?
      gender == "F"
    end

    def male?
      gender == "M"
    end

    def non_binary?
      gender == "NB"
    end
  end
end
