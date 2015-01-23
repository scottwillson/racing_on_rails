ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require "rails/test_help"
require "mocha/setup"
require "action_view/test_case"
require "authlogic/test_case"
require "test/enumerable_assertions"

# Use transactional fixtures except for acceptance environment
class ActiveSupport::TestCase
  make_my_diffs_pretty!

  self.use_transactional_fixtures = false
  self.use_instantiated_fixtures  = false
  self.pre_loaded_fixtures  = false

  include Authlogic::TestCase
  include Test::EnumerableAssertions

  DatabaseCleaner.strategy = :truncation

  FakeWeb.allow_net_connect = false
  FakeWeb.register_uri :put, %r{http://localhost:9200/posts/post/*}, body: "{}"

  setup :clean_database, :activate_authlogic, :reset_association, :reset_disciplines, :reset_person_current

  def clean_database
    DatabaseCleaner.clean
  end

  def reset_association
    RacingAssociation.current = nil
  end

  def reset_disciplines
    # Discipline class may have loaded earlier with no aliases in database
    Discipline.reset
  end

  def reset_person_current
    Person.current = nil
  end

  # person = fixture symbol or Person
  def login_as(person)
    case person
    when Symbol
      PersonSession.create FactoryGirl.create(person).reload
    when Person
      PersonSession.create person.reload
    else
      raise "Don't recognize #{person}"
    end
  end

  def logout
    session[:person_credentials_id] = nil
    session[:person_credentials] = nil
  end

  # person = fixture symbol or Person
  def goto_login_page_and_login_as(person, password = "secret")
    person = case person
    when Symbol
      people(person)
    when Person
      person
    else
      raise "Don't recognize #{person}"
    end

    https! if RacingAssociation.current.ssl?
    get new_person_session_path
    assert_response :success
    assert_template "person_sessions/new"

    post person_session_path, person_session: { login: person.login, password: password }
    assert_response :redirect
  end

  # Assert Arrays of Results are the same. Only considers place, Person, and time
  def assert_results(expected, actual, message = nil)
    assert_equal(expected.size, actual.size, "Size of results. #{message}")
    expected.each_with_index {|result, index|
      assert_equal((index + 1).to_s, actual[index].place.to_s, "place for #{result}. #{message}")
      assert_equal(result.person, actual[index].person, "person for #{result}. #{message}")
      assert_equal(result.time, actual[index].time, "time for #{result}. #{message}")
    }
  end

  # Expected = date in yyyy-mm-dd format
  def assert_equal_dates(expected, actual, message = nil, format = "%Y-%m-%d")
    if expected != nil && (expected.is_a?(Date) || expected.is_a?(DateTime) || expected.is_a?(Time))
      expected = expected.strftime(format)
    end
    formatted_actual = actual
    if !actual.nil? and (actual.is_a?(Date) || actual.is_a?(DateTime) || actual.is_a?(Time))
      formatted_actual = actual.strftime(format)
    end
    flunk("#{message} \nExpected #{expected} \nbut was #{formatted_actual}") unless expected == formatted_actual
  end

  def assert_equal_events(expected, actual, message = 'Events not equal')
    expected_sorted = expected.sort_by(&:name)
    actual_sorted = actual ? actual.sort_by(&:name) : []
    unless expected_sorted == actual_sorted
      expected_formatted = expected_sorted.join("\n")
      actual_formatted = actual_sorted.join("\n")
      detailed_message = "#{message}. Expected:\n#{expected_formatted} \nbut was:\n#{actual_formatted}"
      flunk(detailed_message)
    end
  end

  def create_administrator_session
    @administrator = Person.find_by_login("admin@example.com") || FactoryGirl.create(:administrator)
    PersonSession.create(@administrator)
  end

  def use_ssl
    (@request.env['HTTPS'] = 'on') if RacingAssociation.current.ssl?
  end

  def use_http
    @request.env.delete('HTTPS')
  end

  def destroy_person_session
    session["person_credentials"] = nil
  end

  def print_all_events
    Event.order(:date).each {|event|
      p "#{event.date} #{event.name} id: #{event.id} parent: #{event.parent_id} #{event.class} #{event.sanctioned_by} #{event.discipline}"
    }.size
  end

  def print_all_results
    Result.order(:person_id).each {|result|
      p "#{result.place} (#{result.members_only_place}) #{result.name} #{result.team} #{result.event.name} #{result.race.name} #{result.date} BAR: #{result.bar}"
    }.size
  end

  def print_all_categories
    Category.order('parent_id, name').each {|category|
      p "#{category.id} #{category.parent_id} #{category.name}"
    }.size
  end

  # helps with place_members_only calculation, so there are no gaps
  def fill_in_missing_results
    Result.all.group_by(&:race).each do |race, results|
       all_results = results.collect(&:place)
       # important to get last place in last
       (1..results.sort.last.numeric_place).reverse_each { |res|
         unless all_results.include?(res.to_s)
           # we need a result, there is a gap here
           race.results.create!(place: res)
         end
       }
    end
  end

  def secure_redirect_options
    @controller.send :secure_redirect_options
  end
end
