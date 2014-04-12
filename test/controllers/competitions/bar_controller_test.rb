require File.expand_path("../../../test_helper", __FILE__)

module Competitions
  # :stopdoc:
  class BarControllerTest < ActionController::TestCase
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::CaptureHelper

    tests ::BarController

    def setup
      super
      big_team = Team.create(:name => "T" * 60)
      weaver = FactoryGirl.create(:person, :first_name => "f" * 60, :last_name => "T" * 60, :team => big_team)
      FactoryGirl.create(:race).results.create! :person => weaver, :team => big_team
      @bar = ::Bar.calculate! 2004
    end

    def test_index
      get :index
      assert_response :success
      assert_template "bar/index"
    end

    def test_show_no_bar
      get :show, :year => "2012"
      assert_response :success
      assert_template "bar/show"
      assert flash.present?, "flash.present?"
    end

    def test_defaults
      get :show, :year => "#{Time.zone.today.year}", :discipline => "overall", :category => "senior_men"
      assert_response :success
      assert_template "bar/show"
    end

    def test_show_empty
      get :show, :year => "#{Time.zone.today.year}", :discipline => "road", :category => "senior_men"
      assert_response :success
      assert_template "bar/show"
    end

    def test_show
      Bar.calculate! Time.zone.today.year
      get :show, :year => "#{Time.zone.today.year}", :discipline => "road", :category => "senior_women"
      assert_response :success
      assert_template "bar/show"
    end

    def test_bad_discipline
      masters_men = Category.find_by_name("Masters Men")
      FactoryGirl.create(:category, :name => "Masters Men 30-34", :parent => masters_men)
      FactoryGirl.create(:discipline, :name => "Overall")
      get :show, :discipline => "badbadbad", :year => "2004", :category => "masters_men_30_34"
      assert_response :success
      assert_template "bar/show"
      assert flash.present?, "flash.present?"
    end

    def test_bad_year
      masters_men = Category.find_by_name("Masters Men")
      FactoryGirl.create(:category, :name => "Masters Men 30-34", :parent => masters_men)
      FactoryGirl.create(:discipline, :name => "Overall")
      get :show, :discipline => "overall", :year => "19", :category => "masters_men_30_34"
      assert_response :success
      assert_template "bar/show"
      assert flash.present?, "flash.present?"
    end

    def test_bad_category
      masters_men = Category.find_by_name("Masters Men")
      FactoryGirl.create(:category, :name => "Masters Men 30-34", :parent => masters_men)
      FactoryGirl.create(:discipline, :name => "Overall")
      get :show, :discipline => "overall", :year => "2009", :category => "dhaskjdhal"
      assert_response :success
      assert_template "bar/show"
      assert flash.present?, "flash.present?"
    end

    # Lib implementation was broken at one point...
    def test_truncate
      name = "Broadmark"
      truncated = truncate name, :length => 5
      assert_equal "Br...", truncated, "truncated Broadmark"

      truncated = truncate name, :length => 9
      assert_equal "Broadmark", truncated, "truncated Broadmark"

      truncated = truncate name, :length => 8
      assert_equal "Broad...", truncated, "truncated Broadmark"
    end
  end
end
