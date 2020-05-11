# frozen_string_literal: true

module Actions
  include ActiveSupport::Concern

  def create_new_login
    fill_in "person_login", with: "kc@iq-9.com"
    fill_in "person_password", with: "condor"
    fill_in "person_name", with: "Kevin Condron"
    fill_in "person_license", with: "576"
    fill_in "person_email", with: "kc@iq-9.com"
    click_button "Save"
  end

  # Go to login page and login
  def login_as(person)
    visit "/person_session/new" unless current_path == "/person_session/new"
    assert_selector "#person_session_login"
    fill_in "person_session_login", with: person.login
    fill_in "person_session_password", with: "secret"
    click_button "login_button"
  end

  def logout
    visit "/logout"
  end

  def visit_event(event)
    click_link event.name
  end
end
