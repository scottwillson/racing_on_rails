require File.expand_path("../../test_case", __FILE__)
require File.expand_path("../../../../lib/page_constraint", __FILE__)
require File.expand_path("../../../../app/models/concerns/page/paths", __FILE__)

# :stopdoc:
class Page
  include Concerns::Page::Paths

  @@paths = []

  def self.exists?(conditions)
    @@paths.include? conditions[:path]
  end

  def self.paths
    @@paths
  end
end

# :stopdoc:
class PageConstraintTest < Ruby::TestCase
  def setup
    Page.paths.clear
  end

  # Not sure if this ever could happen
  def test_nil
    request = stub("request", :path => nil)
    assert !PageConstraint.new.matches?(request), "Nil request"
  end

  # Not sure if this ever could happen
  def test_blank
    request = stub("request", :path => "")
    assert !PageConstraint.new.matches?(request), "blank request"
  end

  def test_root
    request = stub("request", :path => "/")
    assert !PageConstraint.new.matches?(request), "request for root"
  end

  def test_root_with_root_page
    request = stub("request", :path => "/")
    Page.paths << ""
    Page.paths << "foo"
    Page.paths << "foo/bar"
    assert PageConstraint.new.matches?(request), "request for root"
  end

  def test_single_page
    request = stub("request", :path => "/foo")
    Page.paths << ""
    Page.paths << "foo"
    Page.paths << "foo/bar"
    assert PageConstraint.new.matches?(request), "request for /foo"
  end

  def test_multiple_path
    request = stub("request", :path => "/foo/bar")
    Page.paths << ""
    Page.paths << "foo"
    Page.paths << "foo/bar"
    assert PageConstraint.new.matches?(request), "request for /foo/bar"
  end

  def test_multiple_path_no_match
    request = stub("request", :path => "/bat/baz")
    Page.paths << ""
    Page.paths << "foo"
    Page.paths << "foo/bar"
    assert !PageConstraint.new.matches?(request), "request for /bat/baz"
  end

  def test_root_index
    request = stub("request", :path => "/index")
    Page.paths << ""
    assert PageConstraint.new.matches?(request), "request for root"
  end

  def test_child_index
    request = stub("request", :path => "/foo/index")
    Page.paths << ""
    Page.paths << "foo"
    Page.paths << "foo/bar"
    assert PageConstraint.new.matches?(request), "request for child index"
  end

  def test_html
    request = stub("request", :path => "/foo.html")
    Page.paths << ""
    Page.paths << "foo"
    Page.paths << "foo/bar"
    assert PageConstraint.new.matches?(request), "request for child index"
  end

  def test_child_html
    request = stub("request", :path => "/foo/bar.html")
    Page.paths << ""
    Page.paths << "foo"
    Page.paths << "foo/bar"
    assert PageConstraint.new.matches?(request), "request for child index"
  end

  def test_index_html
    request = stub("request", :path => "/index.html")
    Page.paths << ""
    assert PageConstraint.new.matches?(request), "request for root"
  end

  def test_child_index_html
    request = stub("request", :path => "/foo/index.html")
    Page.paths << ""
    Page.paths << "foo"
    Page.paths << "foo/bar"
    assert PageConstraint.new.matches?(request), "request for child index"
  end
end
