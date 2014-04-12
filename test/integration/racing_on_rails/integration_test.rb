require_relative "../../test_helper"

module RacingOnRails
  class IntegrationTest < ActionDispatch::IntegrationTest
    def go_to_login
      https! if RacingAssociation.current.ssl?
      get new_person_session_path
      assert_response :success
      assert_template "person_sessions/new"
    end

    def login(options)
      https! if RacingAssociation.current.ssl?
      post person_session_path, options
      assert_response :redirect
    end
  end
end
