# Permissions. Only used for Administrator which could be replaced with admin? attribute.
class Role < ActiveRecord::Base
  has_and_belongs_to_many :people
end
