require "acceptance/webdriver_test_case"

class VelodromesTest < WebDriverTestCase
  def test_velodromes
    login_as :administrator

    open "/admin/velodromes"

    assert_table("velodromes_table", 1, 0, /^Alpenrose Dairy/)
    assert_table("velodromes_table", 1, 1, /^http:\/\/www.obra.org\/track\//)
    assert_table("velodromes_table", 2, 0, /^Valley Preferred Cycling Center/)
    assert_table("velodromes_table", 2, 1, /^http:\/\/www.lvvelo.org\//)

    click "velodrome_#{Velodrome.find_by_name('Valley Preferred Cycling Center').id}_website"
    wait_for_element :class_name => "editor_field"
    type "http://example.com", :class_name => "editor_field"
     type :return, { :class_name => "editor_field" }, false
    wait_for_no_element :class_name => "editor_field"

    refresh
    wait_for_element "velodromes_table"
    assert_table("velodromes_table", 2, 1, /^http:\/\/example.com/)

    click :css => "a[href='/admin/velodromes/#{Velodrome.find_by_name('Valley Preferred Cycling Center').id}/edit']"
    assert_value "Valley Preferred Cycling Center", "velodrome_name"
    assert_value "http://example.com", "velodrome_website"

    type "T-Town", "velodrome_name"
    click "save"
    wait_for_value "T-Town", "velodrome_name"
  end
end
