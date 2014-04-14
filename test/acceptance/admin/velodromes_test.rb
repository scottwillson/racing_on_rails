require File.expand_path(File.dirname(__FILE__) + "/../acceptance_test")

# :stopdoc:
class VelodromesTest < AcceptanceTest
  def test_velodromes
    javascript!

    login_as FactoryGirl.create(:administrator)
    FactoryGirl.create(:velodrome, name: "Alpenrose Dairy", website: "http://www.obra.org/track/")
    t_town = FactoryGirl.create(:velodrome, name: "Valley Preferred Cycling Center", website: "http://www.lvvelo.org/")

    visit "/admin/velodromes"

    assert_table("velodromes_table", 2, 2, "Alpenrose Dairy")
    assert_table("velodromes_table", 2, 3, "http://www.obra.org/track/")
    assert_table("velodromes_table", 3, 2, "Valley Preferred Cycling Center")
    assert_table("velodromes_table", 3, 3, "http://www.lvvelo.org/")

    fill_in_inline "#velodrome_#{t_town.id}_website", with: "http://example.com"
    visit "/admin/velodromes"
    assert_table("velodromes_table", 3, 3, "http://example.com")

    click_link "edit_#{t_town.id}"
    assert_equal "Valley Preferred Cycling Center", find_field("velodrome_name").value
    assert_equal "http://example.com", find_field("velodrome_website").value

    fill_in "velodrome_name", with: "T-Town"
    click_button "Save"
  end
end
