# audit of source file for results and membership uploads
class ImportFile < ActiveRecord::Base
  validates_presence_of :name
end
