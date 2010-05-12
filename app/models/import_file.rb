class ImportFile < ActiveRecord::Base
  validates_presence_of :name
  
  # Consistent API for created_by block
  def name_or_login
    name
  end
end
