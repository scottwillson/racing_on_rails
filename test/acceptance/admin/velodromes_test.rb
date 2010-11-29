require "acceptance/webdriver_test_case"

# :stopdoc:
class VelodromesTest < WebDriverTestCase
  def test_velodromes
    login_as :administrator

    open "/admin/velodromes"

    assert_table("velodromes_table", 1, 0, /^Alpenrose Dairy/)
    assert_table("velodromes_table", 1, 1, /^http:\/\/www.obra.org\/track\//)
    assert_table("velodromes_table", 2, 0, /^Valley Preferred Cycling Center/)
    assert_table("velodromes_table", 2, 1, /^http:\/\/www.lvvelo.org\//)

    click "velodrome_#{Velodrome.find_by_name('Valley Preferred Cycling Center').id}_website"
    wait_for_element :class_name => "form.editor_field input"
    type "http://example.com", :class_name => "form.editor_field input"
     type :return, { :class_name => "form.editor_field input" }, false
    wait_for_no_element :class_name => "form.editor_field input"

    refresh
    wait_for_element "velodromes_table"
    assert_table("velodromes_table", 2, 1, /^http:\/\/example.com/)

    click "edit_#{Velodrome.find_by_name('Valley Preferred Cycling Center').id}"
    wait_for_element "velodrome_name"
    assert_value "Valley Preferred Cycling Center", "velodrome_name"
    assert_value "http://example.com", "velodrome_website"

    type "T-Town", "velodrome_name"
    click "save"
    wait_for_value "T-Town", "velodrome_name"
  end
end
