module Photos
  module Dimensions
    extend ActiveSupport::Concern

    def landscape?
      if height && width
        height <= width
      else
        false
      end
    end

    def portrait?
      if height && width
        height > width
      else
        false
      end
    end

    def widescreen?
      if height && width
        width.to_f / height >= 1.37
      else
        false
      end
    end
  end
end
