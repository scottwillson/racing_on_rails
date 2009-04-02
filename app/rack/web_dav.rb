require 'builder'
require 'rack/auth/basic'
# require 'ostruct'

module Rack
  class WebDAV < Rack::Auth::Basic
    def initialize(app)
      super(app) do |username, password|
        user = User.find_by_email(username)
        user && user.password == password
      end
      self.realm = "Racing on Rails pages"
    end

    def call(env)
      return @app.call(env) unless web_dav_client?(env)

      # p "*" * 80
      # r = Rack::Request.new(env)
      # r.env.each { |e| p "ENV #{e.inspect}" }
      # r.params.each { |param| p "PARAM #{p.inspect}" }
      # p r.body.string
      # p "-" * 80

      auth = Rack::Auth::Basic::Request.new(env)
      return unauthorized unless auth.provided?
      return bad_request unless auth.basic?
      return unauthorized unless valid?(auth)
      
      env["REMOTE_USER"] = auth.username

      web_dav_response = handle_web_dav(env)

      # p web_dav_response
      # p "*" * 80

      web_dav_response
    end
    
    def handle_web_dav(env)
      path        = (env['PATH_INFO'] || "").chomp('/')
      method      = env['REQUEST_METHOD']

      # Rendudant, yes, but also fast, safe, and explicit
      case method
      when "OPTIONS"
        options
      when "PROPFIND"
        propfind(path, env["HTTP_DEPTH"])
      when "GET"
        get path
      when "LOCK", "UNLOCK"
        ok
      when "PUT"
        put path, env
      when "DELETE"
        delete path
      else
        unsupported(method)
      end
    end
    
    def web_dav_client?(env)
      env["HTTP_USER_AGENT"] && env["HTTP_USER_AGENT"][/webdav|gvfs\/\d/i]
    end
    
    def options
      [200, { "DAV" => "1,2", "Allow" => "LOCK,UNLOCK,OPTIONS,PROPFIND,PROPPATCH,MKCOL,DELETE,PUT,COPY,MOVE", "Content-Type" => "text/xml; charset=utf-8", "Content-Length" => "1" }, [" "]]
    end
    
    def propfind(path, depth = 0)
      depth = depth.to_i
      
      parent = page_find_by_path(path)
      
      return [404, { "Content-Type" => "text/xml; charset=utf-8", "Content-Length" => "1" }, [" "]] unless parent || path == ""

      xml = ::Builder::XmlMarkup.new
      xml.multistatus(:xmlns => "D:DAV") {
        
      if depth == 0
        if path[/index.html$/] && parent
          xml.response {
              xml.href "index.html"
              xml.propstat {
                xml.prop {
                  xml.getlastmodified parent.updated_at.httpdate
                  xml.getcontentlength parent.body.size
                  xml.resourcetype
                }
                xml.status "HTTP/1.1 200 OK"
              }
          }
        else
          if parent.nil? || !parent.children.empty?
            xml.response {
              xml.href web_dav_path(parent)
              xml.propstat {
                xml.prop {
                  if parent && parent.updated_at
                    xml.getlastmodified parent.updated_at.httpdate
                  else
                    xml.getlastmodified "Thu, 19 Mar 2009 23:27:27 GMT"
                  end
                  (xml.getcontentlength(parent.body.size)) if parent
                  xml.resourcetype {
                    xml.collection
                  }
                }
                xml.status "HTTP/1.1 200 OK"
              }
            }
          else
            xml.response {
                xml.href "#{parent.slug}.html"
                xml.propstat {
                  xml.prop {
                    xml.getlastmodified parent.updated_at.httpdate
                    xml.getcontentlength parent.body.size
                    xml.resourcetype
                  }
                  xml.status "HTTP/1.1 200 OK"
                }
            }
          end
        end
      end
      
        if depth > 0
          if parent
            xml.response {
              xml.href "index.html"
              xml.propstat {
                xml.prop {
                  xml.getlastmodified parent.updated_at.httpdate
                  xml.getcontentlength parent.body.size
                  xml.resourcetype
                }
                xml.status "HTTP/1.1 200 OK"
              }
            }
          end
          children = parent ? parent.children : Page.roots
          children.each do |page|
            if !page.children.empty?
              xml.response {
                xml.href web_dav_path(page)
                xml.propstat {
                  xml.prop {
                    xml.getlastmodified page.updated_at.httpdate
                    xml.getcontentlength page.body.size
                    xml.resourcetype {
                      xml.collection
                    }
                  }
                  xml.status "HTTP/1.1 200 OK"
                }
              }
            else
              xml.response {
                xml.href "#{page.slug}.html"
                xml.propstat {
                  xml.prop {
                    xml.getlastmodified page.updated_at.httpdate
                    xml.getcontentlength page.body.size
                    xml.resourcetype
                  }
                  xml.status "HTTP/1.1 200 OK"
                }
              }
            end
          end
        end
      }
      [207, { "Content-Type" => "text/xml; charset=utf-8", "Content-Length" => xml.target!.size.to_s }, [xml.target!]]
    end
    
    def web_dav_path(page)
      return "" unless page
      
      if page.children.empty?
        if page.slug.blank?
          ""
        else
          "#{page.slug}.html"
        end
      else
        page.slug
      end
    end
    
    def get(path)
      page = page_find_by_path path
      return missing unless page
      
      [200, { "Content-Type" => "text/plain", "Content-Length" => page.body.size.to_s }, page.body]
    end
    
    def put(path, env)
      page = page_find_by_path path
      return missing unless page

      page.body = Rack::Request.new(env).body.string
      page.author = User.find_by_email(env["REMOTE_USER"])
      page.save!
      
      # One more messy thing to fix in this class
      ApplicationController.expire_cache
      
      [201, { "Content-Type" => "text/xml; charset=utf-8", "Content-Length" => "1" }, [" "]]
    end
    
    def ok
      [200, { "Content-Type" => "text/xml; charset=utf-8", "Content-Length" => "1" }, [" "]]
    end
    
    def unsupported(method)
      [403, { "Content-Type" => "text/xml; charset=utf-8", "Content-Length" => "1" }, [" "]]
    end
    
    def missing
      [404, { "Content-Type" => "text/xml; charset=utf-8", "Content-Length" => "1" }, [" "]]
    end
    
    # "Null" root special case. We have multiple root Page with no parents
    def root_page
      # unless @root_page
      #   @root_page = OpenStruct.new
      #   @root_page.title = ""
      #   @root_page.path = ""
      #   @root_page.slug = ""
      #   @root_page.children = Page.roots
      # end 
      # @root_page
    end
    
    def to_page_path(request_path)
      return "" unless request_path
      page_path = request_path.gsub(/^\//, "")
      page_path.gsub!(/.html$/, "")
      page_path || ""
    end
  
    def page_find_by_path(path)
      return nil unless path

      page_path = path.gsub(/^\//, "")
      page_path = page_path.gsub(/\/index$/, "") if page_path
      page_path = page_path.gsub(/\/index.html$/, "") if page_path
      page_path.gsub!(/.html$/, "")
      page_path = page_path || ""

      Page.find_by_path(page_path)
    end
    
    def delete(path)
      [204, { "Content-Type" => "text/xml; charset=utf-8", "Content-Length" => "1" }, [" "]]
    end
    
    
    private
    
    # Rack Lint says we need Content-Type header
    def unauthorized(www_authenticate = challenge)
      return [ 401, { 'WWW-Authenticate' => www_authenticate.to_s, "Content-Type" => "text/plain; charset=utf-8" }, [] ]
    end

    def bad_request
      [ 400, { "Content-Type" => "text/plain; charset=utf-8" }, [] ]
    end

  end
end
