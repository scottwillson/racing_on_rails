# Add relative path method so we can use inline-rendered Pages as partials
# Did not copy "memoize :relative_path" from base template. Not sure if it matters.
module ActionView #:nodoc:
  class InlineTemplate #:nodoc:
    def relative_path
      path = File.expand_path(filename)
      path.sub!(/^#{Regexp.escape(File.expand_path(RAILS_ROOT))}\//, '') if defined?(RAILS_ROOT)
      path
    end    
  end
end