module Concerns
  module Category
    module FriendlyParam
      extend ActiveSupport::Concern

      module ClassMethods
        def count_by_friendly_param(param)
          ::Category.where(friendly_param: param).count
        end

        def find_by_friendly_param(param)
          category_count = count_by_friendly_param(param)
          case category_count
          when 0
            nil
          when 1
            ::Category.where(friendly_param: param).first
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
        if name
          name.underscore.gsub('+', '_plus').gsub(/[^\w]+/, '_').gsub(/^_/, '').gsub(/_$/, '').gsub(/_+/, '_')
        else
          ""
        end
      end
    end

    class AmbiguousParamException < Exception
    end
  end
end
