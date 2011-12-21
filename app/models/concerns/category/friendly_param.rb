module Concerns
  module Category
    module FriendlyParam
      extend ActiveSupport::Concern

      module ClassMethods
        def count_by_friendly_param(param)
          ::Category.count :conditions => [ "friendly_param = ?", param ]
        end

        def find_by_friendly_param(param)
          category_count = count_by_friendly_param(param)
          case category_count
          when 0
            nil
          when 1
            ::Category.first(:conditions => ['friendly_param = ?', param])
          else
            raise Concerns::Category::AmbiguousParamException, "#{category_count} occurrences of #{param}"
          end
        end
      end

      def set_friendly_param
        self.friendly_param = to_friendly_param
      end

      # Lowercase underscore
      def to_friendly_param
        name.underscore.gsub('+', '_plus').gsub(/[^\w]+/, '_').gsub(/^_/, '').gsub(/_$/, '').gsub(/_+/, '_')
      end
    end

    class AmbiguousParamException < Exception
    end
  end
end
