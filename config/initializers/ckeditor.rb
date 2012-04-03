if Object.const_defined?("Ckeditor")
  Ckeditor.setup do |config|
    require "ckeditor/orm/active_record"
  end
end
