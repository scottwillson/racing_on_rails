require "acceptance/selenium_test_case"

class VelodromesTest < SeleniumTestCase
  def test_velodromes
    login_as_admin

    open "/admin/velodromes"

    assert_table "velodromes_table", 1, 0, "glob:Alpenrose Dairy*"
    assert_table "velodromes_table", 1, 1, "glob:http://www.obra.org/track/*"
    assert_table "velodromes_table", 2, 0, "glob:Valley Preferred Cycling Center*"
    assert_table "velodromes_table", 2, 1, "glob:http://www.lvvelo.org/*"

    click "velodrome_#{Velodrome.find_by_name('Valley Preferred Cycling Center').id}_website", :wait_for => { :element => "css=.editor_field" }
    type "css=.editor_field", "http://example.com"
    submit "css=.inplaceeditor-form"
    wait_for_ajax
    wait_for :element => "css=.editor_field"

    refresh
    wait_for_page
    assert_table "velodromes_table", 2, 1, "glob:http://example.com*"

    click "css=a[href='/admin/velodromes/#{Velodrome.find_by_name('Valley Preferred Cycling Center').id}/edit']", :wait_for => :page
    assert_value "velodrome_name", "Valley Preferred Cycling Center"
    assert_value "velodrome_website", "http://example.com"

    type "velodrome_name", "T-Town"
    click "save", :wait_for => :page
    assert_value "velodrome_name", "T-Town"
  end
end
