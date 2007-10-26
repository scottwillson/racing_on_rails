# Module to help generate HTML4-valid views
module Html4ify
  
  # Initiate a hash with all the DTD's and their URL's
  DOCTYPES = { 
    :loose => {
      :dtd => "-//W3C//DTD HTML 4.01 Transitional//EN",
      :url => "http://www.w3.org/TR/html4/loose.dtd"
    },
    :strict => {
      :dtd => "-//W3C//DTD HTML 4.01//EN",
      :url => "http://www.w3.org/TR/html4/strict.dtd"
    },
    :frameset => {
      :dtd => "-//W3C//DTD HTML 4.01 Frameset//EN",
      :url => "http://www.w3.org/TR/html4/frameset.dtd"
    }
  }
      
  
  # Create a Document Type Declaration string to be contained in your views.
  # This method takes two optional parameters:
  # [+language+]  Either :html4 or :xhtml11. Defaults to :html4
  # [+type+]      Either :strict, :loose or :frameset. Defaults to :strict
  def doctype(type = :strict)
    begin
      "<!DOCTYPE HTML PUBLIC \"#{DOCTYPES[type][:dtd]}\" \"#{DOCTYPES[type][:url]}\">"
    rescue ArgumentError
      puts "bla"
    end
  end
end

# Override the default tag method to default to open tags instead of XML-ish closed tags.
module ActionView::Helpers::TagHelper
  alias_method :tag_without_html4ify, :tag
  def tag(name, options = nil, open = true)
    tag_without_html4ify(name, options, open)
  end
end

# The tag method is aliased to a safe place (tag_without_error_wrapping) before we get a chance to override it.
class ActionView::Helpers::InstanceTag
  def tag_without_error_wrapping(*args)
    ActionView::Helpers::TagHelper.instance_method(:tag).bind(self).call(*args)
  end
end