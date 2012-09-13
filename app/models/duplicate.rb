# Store Person attributes after import and manually resolve duplicates.
# +new_record+ and +attributes+ are somewhat redundant
class Duplicate < ActiveRecord::Base
  serialize :new_attributes
  validates_presence_of :new_attributes

  has_and_belongs_to_many :people
  
  def person
    @person ||= Person.new(new_attributes)
  end
end
