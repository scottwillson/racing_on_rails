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

  def fill_in_inline(locator, options)
    assert_edit = options.delete(:assert_edit)
    text = options[:with]
    options[:with] = options[:with] + "\n"
    assert_selector locator
    find(locator).click
    fill_in_editor_field options
    assert_no_selector ".editing"
    assert_no_selector ".saving"
    if assert_edit
      within locator do
        assert page.has_content?(text)
      end
    end
  end

  def fill_in_editor_field(options)
    retries = 0
    3.times do
      assert_selector "form.editor_field"
      within "form.editor_field" do
        assert_selector "input[name='value']"
        fill_in "value", options
      end
      return true
    rescue Capybara::ElementNotFound, RuntimeError
      if retries < 3
        retries = + 1
        sleep 0.1
        retry
      else
        raise "#{Regexp.last_match(1)} for fill_in_editor_field(#{options}) after #{retries} tries"
      end
    end
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

  def press_return(field)
    press :return, field
  end

  def press(key, field)
    errors = 0
    begin
      press_once key, field
    rescue StandardError
      errors += 1
      retry if errors < 4
    end
  end

  def press_once(key, field)
    if Capybara.current_driver == :poltergeist
      case key
      when :down
        find_field(field).native.send_keys(:Down)
      when :enter, :return
        find_field(field).native.send_keys(:Enter)
      when :tab
        find_field(field).native.send_keys(:Tab)
      else
        find_field(field).native.send_keys(key)
      end
    elsif Capybara.current_driver == :webkit
      keypress_script = "var e = $.Event('keypress', { keyCode: #{key_code(key)} }); $('##{field}').trigger(e);"
      page.driver.browser.execute_script(keypress_script)
    else
      find_field(field).native.send_keys(key)
    end
  end

  def key_code(key)
    case key
    when :down
      40
    when :enter
      13
    when :return
      10
    when :tab
      9
    else
      key.ord
    end
  end

  def select_existing_event(field, name, search_for = nil)
    select_existing("event", field, name, search_for)
  end

  def select_new_event(field, name)
    select_new("event", field, name)
  end

  def select_existing_person(field, name, search_for = nil)
    select_existing("person", field, name, search_for)
  end

  def select_new_person(field, name)
    select_new("person", field, name)
  end

  def select_existing_team(field, name, search_for = nil)
    select_existing("team", field, name, search_for)
  end

  def select_new_team(field, name)
    select_new("team", field, name)
  end

  def select_existing(type, field, name, search_for)
    assert_no_selector ".modal.in"
    search_for ||= name
    click_button "#{field}_select_modal_button"
    assert_selector ".modal.in"
    fill_in "name", with: search_for

    find("tr[data-#{type}-name=\"#{name}\"]").click
    find("##{field}_name[value=\"#{name}\"]", visible: :hidden)
    assert_equal name, find("##{field}_select_modal_button").text
    assert_no_selector "#updating-order-dialog"
    assert_no_selector ".modal.in"
  end

  def select_new(type, field, name)
    assert_no_selector ".modal.in"
    click_button "#{field}_select_modal_button"
    assert_selector ".modal.in"
    find("#show_#{field}_new_modal").click
    assert_selector "##{field}_select_modal_new_#{type}"
    assert_selector "##{field}_new_#{type}_name"
    fill_in "#{field}_new_#{type}_name", with: name
    find_field("#{field}_new_#{type}_name", wait: 4, with: name)
    find("##{field}_select_modal_new_#{type}_create").click
    find("##{field}_name[value=\"#{name}\"]", visible: :hidden)
    assert_no_selector "#updating-order-dialog"
    assert_no_selector ".modal.in"
  end

  def visit_event(event)
    click_link event.name
    assert_selector ".edit_event"
  end
end
