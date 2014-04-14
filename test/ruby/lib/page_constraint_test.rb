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
  test "nil" do
    request = stub("request", path: nil)
    assert !PageConstraint.new.matches?(request), "Nil request"
  end

  # Not sure if this ever could happen
  test "blank" do
    request = stub("request", path: "")
    assert !PageConstraint.new.matches?(request), "blank request"
  end

  test "root" do
    request = stub("request", path: "/")
    assert !PageConstraint.new.matches?(request), "request for root"
  end

  test "root_with_root_page" do
    request = stub("request", path: "/")
    Page.paths << ""
    Page.paths << "foo"
    Page.paths << "foo/bar"
    assert PageConstraint.new.matches?(request), "request for root"
  end

  test "single_page" do
    request = stub("request", path: "/foo")
    Page.paths << ""
    Page.paths << "foo"
    Page.paths << "foo/bar"
    assert PageConstraint.new.matches?(request), "request for /foo"
  end

  test "multiple_path" do
    request = stub("request", path: "/foo/bar")
    Page.paths << ""
    Page.paths << "foo"
    Page.paths << "foo/bar"
    assert PageConstraint.new.matches?(request), "request for /foo/bar"
  end

  test "multiple_path_no_match" do
    request = stub("request", path: "/bat/baz")
    Page.paths << ""
    Page.paths << "foo"
    Page.paths << "foo/bar"
    assert !PageConstraint.new.matches?(request), "request for /bat/baz"
  end

  test "root_index" do
    request = stub("request", path: "/index")
    Page.paths << ""
    assert PageConstraint.new.matches?(request), "request for root"
  end

  test "child_index" do
    request = stub("request", path: "/foo/index")
    Page.paths << ""
    Page.paths << "foo"
    Page.paths << "foo/bar"
    assert PageConstraint.new.matches?(request), "request for child index"
  end

  test "html" do
    request = stub("request", path: "/foo.html")
    Page.paths << ""
    Page.paths << "foo"
    Page.paths << "foo/bar"
    assert PageConstraint.new.matches?(request), "request for child index"
  end

  test "child_html" do
    request = stub("request", path: "/foo/bar.html")
    Page.paths << ""
    Page.paths << "foo"
    Page.paths << "foo/bar"
    assert PageConstraint.new.matches?(request), "request for child index"
  end

  test "index_html" do
    request = stub("request", path: "/index.html")
    Page.paths << ""
    assert PageConstraint.new.matches?(request), "request for root"
  end

  test "child_index_html" do
    request = stub("request", path: "/foo/index.html")
    Page.paths << ""
    Page.paths << "foo"
    Page.paths << "foo/bar"
    assert PageConstraint.new.matches?(request), "request for child index"
  end
end
