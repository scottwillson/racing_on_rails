require File.expand_path(File.dirname(__FILE__) + "/../acceptance_test")

# :stopdoc:
module Admin
  class HomeTest < AcceptanceTest
    def test_edit
      visit "/"
      login_as FactoryGirl.create(:administrator)

      visit "/photos/new"
      attach_file "photo_image", "#{Rails.root}/test/fixtures/photo.jpg"
      fill_in "Caption", :with => "Bike racer wins the bike race"
      click_button "Save"

      assert_equal "1079", find("#photo_height").text
      assert_equal "1438", find("#photo_width").text

      visit "/home/edit"
    end
  end
end
