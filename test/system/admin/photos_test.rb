# frozen_string_literal: true

require "application_system_test_case"

# :stopdoc:
module Admin
  class PhotosTest < ApplicationSystemTestCase
    test "edit" do
      visit "/"
      login_as FactoryBot.create(:administrator)

      visit "/photos/new"
      attach_file "photo_image", "#{Rails.root}/test/fixtures/files/photo.jpg"
      fill_in "Caption", with: "Bike racer wins the bike race"
      click_button "Save"

      assert_equal "900", find("#photo_height").text
      assert_equal "1199", find("#photo_width").text
    end
  end
end
