# TODO: +new_record+ and +attributes+ are somewhat redundant
class Duplicate
  
  attr_accessor :new_record, :existing_records, :attributes
  
  def initialize(new_record, new_attributes, existing_records)
    @new_record = new_record
    @attributes = new_attributes
    @existing_records = existing_records
  end
end