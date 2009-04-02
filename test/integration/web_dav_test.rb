require 'test_helper'

# TODO Switch to empty arrays for blank responses

class WebDAVTest < ActionController::IntegrationTest
  def test_unauthenticated_handshake
    options("/", {}, os_x_client)
  
    assert_equal 401, status
  end
  
  def test_handshake
    options("/", {}, os_x_client + admin_user)
  
    assert_equal 200, status
    assert_equal "1,2", headers["DAV"], "headers[DAV]"
    assert_equal "LOCK,UNLOCK,OPTIONS,PROPFIND,PROPPATCH,MKCOL,DELETE,PUT,COPY,MOVE", headers["Allow"], "headers[Allow]"
    assert_equal "text/xml; charset=utf-8", headers["Content-Type"], "headers[Content-Type]"
    assert_equal "1", headers["Content-Length"], "headers[Content-Length]"
  end
  
  def test_directory_listing
    propfind( "/", 
              { "propfind" => { "prop" => { "getcontentlength" => nil, "getlastmodified"=>nil, "resourcetype"=>nil }, "xmlns:d" => "DAV:" } },
              os_x_client + admin_user + depth(0))
  
    xml = Hash.from_xml(@response.body)
    assert(xml["multistatus"], "root element in response #{xml.inspect}")
    assert_equal(nil, xml["multistatus"]["response"]["href"], "href for page in response #{xml.inspect}")
    assert_equal({ "collection" => nil }, xml["multistatus"]["response"]["propstat"]["prop"]["resourcetype"], "collection in response #{xml.inspect}")
    assert_equal "text/xml; charset=utf-8", headers["Content-Type"], "headers[Content-Type]"
    assert_equal "247", headers["Content-Length"], "headers[Content-Length]"
  end
  
  def test_directory_listing_depth_1
    propfind( "/", 
              { "propfind" => { "prop" => { "getcontentlength" => nil, "getlastmodified"=>nil, "resourcetype"=>nil }, "xmlns:d" => "DAV:" } },
              os_x_client + admin_user + depth(1))
  
    xml = Hash.from_xml(@response.body)    
    assert(xml["multistatus"], "root element in response #{xml.inspect}")
    assert_equal nil, xml["multistatus"]["response"]["propstat"]["prop"]["resourcetype"], "collection in response #{xml.inspect}"
    assert_equal "plain.html", xml["multistatus"]["response"]["href"], "href for page in response #{xml.inspect}"
    assert_equal "text/xml; charset=utf-8", headers["Content-Type"], "headers[Content-Type]"
    assert_equal "269", headers["Content-Length"], "headers[Content-Length]"
  end
  
  def test_get_content
    get("/plain.html", {}, os_x_client + admin_user)
    assert_equal 200, status
    assert_equal "<p>This is a plain page</p>", @response.body, "body content"
    assert_equal "27", headers["Content-Length"], "headers[Content-Length]"
  end
  
  def test_get_content_for_index_page
    root = pages(:plain)
    child = root.children.create!(:title => "Child Page")
  
    get("/plain/index.html", {}, os_x_client + admin_user)
    assert_equal 200, status
    assert_equal "<p>This is a plain page</p>", @response.body, "body content"
    assert_equal "27", headers["Content-Length"], "headers[Content-Length]"
  end
  
  def test_lock_for_update
    lock("/plain.html", {}, os_x_client + admin_user)
    assert_equal 200, status, "HTTP status"
    assert_equal " ", @response.body, "response body"
    assert_equal "1", headers["Content-Length"], "headers[Content-Length]"
  end
  
  def test_unlock
    unlock("/plain.html", {}, os_x_client + admin_user)
    assert_equal 200, status, "HTTP status"
    assert_equal " ", @response.body, "response body"
    assert_equal "1", headers["Content-Length"], "headers[Content-Length]"
  end
  
  def test_update
    put("/plain.html", "New page body content", os_x_client + admin_user)
    assert_equal 201, status, "HTTP status"
    page = pages(:plain)
    page.reload
    assert_equal "New page body content", page.body, "Updated page body"
    assert_equal "1", headers["Content-Length"], "headers[Content-Length]"
    assert_equal users(:administrator), page.author, "Update author"
  end
  
  def test_display_pages_with_children_as_directories
    root = pages(:plain)
    child = root.children.create!(:title => "Child Page")
  
    propfind( "/", 
              { "propfind" => { "prop" => { "getcontentlength" => nil, "getlastmodified"=>nil, "resourcetype"=>nil }, "xmlns:d" => "DAV:" } },
              os_x_client + admin_user + depth(0))
  
    xml = Hash.from_xml(@response.body)
    assert(xml["multistatus"], "root element in response #{xml.inspect}")
    assert_equal nil, xml["multistatus"]["response"]["href"], "href for page in response #{xml.inspect}"
    assert_equal "text/xml; charset=utf-8", headers["Content-Type"], "headers[Content-Type]"
    assert_equal "247", headers["Content-Length"], "headers[Content-Length]"
  end
  
  def test_display_pages_with_children_as_directories_depth_1
    root = pages(:plain)
    child = root.children.create!(:title => "Child Page")
  
    propfind( "/", 
              { "propfind" => { "prop" => { "getcontentlength" => nil, "getlastmodified"=>nil, "resourcetype"=>nil }, "xmlns:d" => "DAV:" } },
              os_x_client + admin_user + depth(1))
  
    xml = Hash.from_xml(@response.body)
    assert(xml["multistatus"], "root element in response #{xml.inspect}")
    assert_equal "plain", xml["multistatus"]["response"]["href"], "href for page in response #{xml.inspect}"
    assert_equal "text/xml; charset=utf-8", headers["Content-Type"], "headers[Content-Type]"
    assert_equal "291", headers["Content-Length"], "headers[Content-Length]"
  end
  
  def test_root_directory_with_child_depth_1
    root = pages(:plain)
    child = root.children.create!(:title => "Child Page")
  
    propfind( "", 
              { "propfind" => { "prop" => { "getcontentlength" => nil, "getlastmodified"=>nil, "resourcetype"=>nil }, "xmlns:d" => "DAV:" } },
              os_x_client + admin_user + depth(1))
  
    xml = Hash.from_xml(@response.body)
    assert(xml["multistatus"], "root element in response #{xml.inspect}")
    assert_equal({ "collection" => nil }, xml["multistatus"]["response"]["propstat"]["prop"]["resourcetype"], "collection in response #{xml.inspect}")
    assert_equal "plain", xml["multistatus"]["response"]["href"], "href for page in response #{xml.inspect}"
    assert_equal "text/xml; charset=utf-8", headers["Content-Type"], "headers[Content-Type]"
    assert_equal "291", headers["Content-Length"], "headers[Content-Length]"
  end
  
  def test_display_subdirectory
    root = pages(:plain)
    child = root.children.create!(:title => "Child Page")
  
    propfind( "/plain", 
              { "propfind" => { "prop" => { "getcontentlength" => nil, "getlastmodified"=>nil, "resourcetype"=>nil }, "xmlns:d" => "DAV:" } },
              os_x_client + admin_user + depth(0))
  
    xml = Hash.from_xml(@response.body)
    assert(xml["multistatus"], "root element in response #{xml.inspect}")
    assert_equal({ "collection" => nil }, xml["multistatus"]["response"]["propstat"]["prop"]["resourcetype"], "collection in response #{xml.inspect}")
    assert_equal "plain", xml["multistatus"]["response"]["href"], "href for page in response #{xml.inspect}"
    assert_equal "text/xml; charset=utf-8", headers["Content-Type"], "headers[Content-Type]"
    assert_equal "291", headers["Content-Length"], "headers[Content-Length]"
  end
  
  def test_display_subdirectory_depth_1
    root = pages(:plain)
    child = root.children.create!(:title => "Child Page")
  
    propfind( "/plain", 
              { "propfind" => { "prop" => { "getcontentlength" => nil, "getlastmodified"=>nil, "resourcetype"=>nil }, "xmlns:d" => "DAV:" } },
              os_x_client + admin_user + depth(1))
  
    xml = Hash.from_xml(@response.body)
    assert(xml["multistatus"], "root element in response #{xml.inspect}")
    assert_equal "index.html", xml["multistatus"]["response"][0]["href"], "href for page in response #{xml.inspect}"
    assert_equal "child_page.html", xml["multistatus"]["response"][1]["href"], "href for page in response #{xml.inspect}"
    assert_equal "text/xml; charset=utf-8", headers["Content-Type"], "headers[Content-Type]"
    assert_equal "501", headers["Content-Length"], "headers[Content-Length]"
  end
  
  def test_directory_listing_for_dot_files
    propfind( "/.DS_Store", 
              { "propfind" => { "prop" => { "getcontentlength" => nil, "getlastmodified"=>nil, "resourcetype"=>nil }, "xmlns:d" => "DAV:" } },
              os_x_client + admin_user)
  
    assert_equal 404, status
  
    propfind( "/.index.html", 
              { "propfind" => { "prop" => { "getcontentlength" => nil, "getlastmodified"=>nil, "resourcetype"=>nil }, "xmlns:d" => "DAV:" } },
              os_x_client + admin_user)
  
    assert_equal 404, status
    assert_equal "1", headers["Content-Length"], "headers[Content-Length]"
  end
  
  def os_x_client
    { "HTTP_USER_AGENT" => "WebDAVFS/1.7 (01708000) Darwin/9.6.0 (i386)" }
  end
  
  def admin_user
    { "HTTP_AUTHORIZATION" => "Basic YWRtaW5AZXhhbXBsZS5jb206c2VjcmV0", "REMOTE_USER" => users(:administrator).email }
  end
  
  def depth(value)
    { "HTTP_DEPTH" => value.to_s }
  end
  
  def lock(path, parameters = nil, headers = nil)
    process :lock, path, parameters, headers
  end

  def options(path, parameters = nil, headers = nil)
    process :options, path, parameters, headers
  end

  def propfind(path, parameters = nil, headers = nil)
    process :propfind, path, parameters, headers
  end

  def unlock(path, parameters = nil, headers = nil)
    process :unlock, path, parameters, headers
  end
  
end

class Hash
  def +(hash)
    self.merge(hash)
  end
end
