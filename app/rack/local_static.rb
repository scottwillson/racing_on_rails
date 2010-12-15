require 'rack/utils'

module Rack
  # Test custom static asset overrides in development mode.
  # Looks for stylesheets, JavaScripts, etc. in local/public. Handled by web server in production.
  class LocalStatic
    FILE_METHODS = %w(GET HEAD).freeze

    def initialize(app)
      @app = app
      @local_file_server = ::Rack::File.new(::File.join(::Rails.root.to_s, "local", "public"))
    end

    def call(env)
      path        = env['PATH_INFO'].chomp('/')
      method      = env['REQUEST_METHOD']
      cached_path = (path.empty? ? 'index' : path) + ::ActionController::Base.page_cache_extension

      if FILE_METHODS.include?(method)
        if local_file_exist?(path)
          return @local_file_server.call(env)
        elsif local_file_exist?(cached_path)
          env['PATH_INFO'] = cached_path
          return @local_file_server.call(env)
        end
      end

      @app.call(env)
    end

    private
      def local_file_exist?(path)
        full_path = ::File.join(@local_file_server.root, ::Rack::Utils.unescape(path))
        ::File.file?(full_path) && ::File.readable?(full_path)
      end
  end
end
