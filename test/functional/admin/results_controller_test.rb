require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class Admin::ResultsControllerTest < ActionController::TestCase
  def setup
    super
    create_administrator_session
    use_ssl
  end
  
  def test_update_no_team
    weaver_jack_frost = results(:weaver_jack_frost)
    weaver_jack_frost.team = nil
    weaver_jack_frost.save!

    team_name = ''

    xhr :put,
        :update_attribute,
        :id => weaver_jack_frost.to_param,
        :name => "team_name",
        :value => team_name
    assert_response(:success)

    weaver_jack_frost.reload
    assert_nil(weaver_jack_frost.team(true), 'team')
  end
  
  def test_update_no_team_to_existing
    weaver_jack_frost = results(:weaver_jack_frost)
    weaver_jack_frost.team = nil
    weaver_jack_frost.save!
    
    xhr :put,
        :update_attribute,
        :id => weaver_jack_frost.to_param,
        :name => "team_name",
        :value => teams(:vanilla).name
    assert_response(:success)
    assert_response(:success)

    weaver_jack_frost.reload
    assert_equal(teams(:vanilla), weaver_jack_frost.team(true), 'team')
  end
  
  def test_update_no_team_to_new
    weaver_jack_frost = results(:weaver_jack_frost)
    weaver_jack_frost.team = nil
    weaver_jack_frost.save!

    xhr :put,
        :update_attribute,
        :id => weaver_jack_frost.to_param,
        :name => "team_name",
        :value => "Team Vanilla"
    assert_response(:success)

    weaver_jack_frost.reload
    assert_equal("Team Vanilla", weaver_jack_frost.team(true).name, "team name")
    assert_not_equal(teams(:vanilla), weaver_jack_frost.team(true), "Should create new team")
  end
  
  def test_update_no_team_to_alias
    weaver_jack_frost = results(:weaver_jack_frost)
    weaver_jack_frost.team = nil
    weaver_jack_frost.save!

    team_name = 'Gentile Lovers'
    
    xhr :put,
        :update_attribute,
        :id => weaver_jack_frost.to_param,
        :name => "team_name",
        :value => team_name
    assert_response(:success)

    weaver_jack_frost.reload
    assert_equal(teams(:gentle_lovers), weaver_jack_frost.team(true), 'team')
  end
  
  def test_update_to_no_team
    weaver_jack_frost = results(:weaver_jack_frost)

    team_name = ''
    
    xhr :put,
        :update_attribute,
        :id => weaver_jack_frost.to_param,
        :name => "team_name",
        :value => team_name
    assert_response(:success)

    weaver_jack_frost.reload
    assert_nil(weaver_jack_frost.team(true), 'team')
  end
  
  def test_update_to_existing_team
    weaver_jack_frost = results(:weaver_jack_frost)

    team_name = 'Vanilla'
    
    xhr :put,
        :update_attribute,
        :id => weaver_jack_frost.to_param,
        :name => "team_name",
        :value => team_name
    assert_response(:success)

    weaver_jack_frost.reload
    assert_equal(teams(:vanilla), weaver_jack_frost.team(true), 'team')
  end
  
  def test_update_to_new_team
    weaver_jack_frost = results(:weaver_jack_frost)

    team_name = 'Astana'
    
    xhr :put,
        :update_attribute,
        :id => weaver_jack_frost.to_param,
        :name => "team_name",
        :value => team_name
    assert_response(:success)

    weaver_jack_frost.reload
    assert_equal(team_name, weaver_jack_frost.team(true).name, 'team name')
  end
  
  def test_update_to_team_alias
    weaver_jack_frost = results(:weaver_jack_frost)

    team_name = 'Gentile Lovers'
    
    xhr :put,
        :update_attribute,
        :id => weaver_jack_frost.to_param,
        :name => "team_name",
        :value => team_name
    assert_response(:success)

    weaver_jack_frost.reload
    assert_equal(teams(:gentle_lovers), weaver_jack_frost.team(true), 'team')
  end
  
  def test_set_result_points
    assert(people(:weaver).aliases(true).empty?)
    weaver_jack_frost = results(:weaver_jack_frost)
    assert_equal(0, weaver_jack_frost.points, 'points')

    xhr :put,
        :update_attribute,
        :id => weaver_jack_frost.to_param,
        :name => "points",
        :value => "12"
    assert_response(:success)

    weaver_jack_frost.reload
    assert_equal(12, weaver_jack_frost.points, 'points')
  end
  
  def test_update_no_person
    weaver_jack_frost = results(:weaver_jack_frost)
    weaver_jack_frost.person = nil
    weaver_jack_frost.save!

    original_team_name = weaver_jack_frost.team_name
    
    xhr :put,
        :update_attribute,
        :id => weaver_jack_frost.to_param,
        :name => "team_name",
        :value => original_team_name
    assert_response(:success)

    weaver_jack_frost.reload
    assert_equal(nil, weaver_jack_frost.first_name, 'first_name')
    assert_equal(nil, weaver_jack_frost.last_name, 'last_name')
    assert_equal(original_team_name, weaver_jack_frost.team_name, 'team_name')
    assert_nil(weaver_jack_frost.person(true), 'person')
  end
  
  def test_update_no_person_to_existing
    weaver_jack_frost = results(:weaver_jack_frost)
    weaver_jack_frost.person = nil
    weaver_jack_frost.save!

    original_team_name = weaver_jack_frost.team_name
    
    xhr :put,
        :update_attribute,
        :id => weaver_jack_frost.to_param,
        :name => "name",
        :value => "Erik Tonkin"
    assert_response(:success)
    
    weaver_jack_frost.reload
    assert_equal("Erik Tonkin", weaver_jack_frost.name, 'name')
    assert_equal(original_team_name, weaver_jack_frost.team_name, 'team_name')
    assert_equal(people(:tonkin), weaver_jack_frost.person(true), 'person')
    assert_equal(1, people(:tonkin).aliases.size)
  end
  
  def test_update_no_person_to_alias
    weaver_jack_frost = results(:weaver_jack_frost)
    weaver_jack_frost.person = nil
    weaver_jack_frost.save!

    original_team_name = weaver_jack_frost.team_name
    
    xhr :put,
        :update_attribute,
        :id => weaver_jack_frost.to_param,
        :name => "name",
        :value => "Erik Tonkin"
    assert_response(:success)

    weaver_jack_frost.reload
    assert_equal('Erik Tonkin', weaver_jack_frost.name, 'name')
    assert_equal(original_team_name, weaver_jack_frost.team_name, 'team_name')
    assert_equal(people(:tonkin), weaver_jack_frost.person(true), 'person')
    assert_equal(1, people(:tonkin).aliases.size)
  end
  
  def test_update_to_no_person
    weaver_jack_frost = results(:weaver_jack_frost)

    original_team_name = weaver_jack_frost.team_name
    
    xhr :put,
        :update_attribute,
        :id => weaver_jack_frost.to_param,
        :name => "name",
        :value => ""
    assert_response(:success)

    weaver_jack_frost.reload
    assert_equal(nil, weaver_jack_frost.first_name, 'first_name')
    assert_equal(nil, weaver_jack_frost.last_name, 'last_name')
    assert_equal(original_team_name, weaver_jack_frost.team_name, 'team_name')
    assert_nil(weaver_jack_frost.person(true), 'person')
  end
  
  def test_update_to_different_person
    assert_equal(1, people(:tonkin).aliases.size)
    weaver_jack_frost = results(:weaver_jack_frost)

    original_team_name = weaver_jack_frost.team_name
    
    xhr :put,
        :update_attribute,
        :id => weaver_jack_frost.to_param,
        :name => "name",
        :value => "Erik Tonkin"
    assert_response(:success)

    weaver_jack_frost.reload
    assert_equal("Erik", weaver_jack_frost.first_name, 'first_name')
    assert_equal("Tonkin", weaver_jack_frost.last_name, 'last_name')
    assert_equal(original_team_name, weaver_jack_frost.team_name, 'team_name')
    assert_equal(people(:tonkin), weaver_jack_frost.person(true), 'person')
    assert_equal(1, people(:tonkin).aliases.size)
  end
  
  def test_update_to_alias
    weaver_jack_frost = results(:weaver_jack_frost)
    original_team_name = weaver_jack_frost.team_name
    assert_equal(1, people(:tonkin).aliases.size)
    
    xhr :put,
        :update_attribute,
        :id => weaver_jack_frost.to_param,
        :name => "name",
        :value => "Erik Tonkin"
    assert_response(:success)
    
    weaver_jack_frost.reload
    assert_equal(people(:tonkin), weaver_jack_frost.person, "Result person")
    assert_equal('Erik', weaver_jack_frost.first_name, 'first_name')
    assert_equal("Tonkin", weaver_jack_frost.last_name, 'last_name')
    assert_equal(original_team_name, weaver_jack_frost.team_name, 'team_name')
    assert_equal(people(:tonkin), weaver_jack_frost.person(true), 'person')
    assert_equal(1, people(:tonkin).aliases.size)
  end
  
  def test_update_to_new_person
    weaver = people(:weaver)
    assert_equal 0, weaver.aliases.size, "aliases"
    assert_equal 4, weaver.results.size, "results"
    result = results(:weaver_jack_frost)
    
    xhr :put,
        :update_attribute,
        :id => result.to_param,
        :name => "name",
        :value => "Stella Carey"

    assert_response :success

    result = Result.find(result.id)
    assert_equal "Stella", result.first_name, "first_name"
    assert_equal "Carey", result.last_name, "last_name"
    assert weaver != result.person, "Result should be associated with a different person"
    assert_equal 0, result.person.aliases.size, "Result person aliases"
    assert_equal 2, result.person.results.size, "Result person results"
    weaver = Person.find(weaver.id)
    assert_equal 0, weaver.aliases.size, "Weaver aliases"
    assert_equal "Ryan", weaver.first_name, "first_name"
    assert_equal "Weaver", weaver.last_name, "last_name"
    assert_equal 3, weaver.results.size, "results"
  end
  
  def test_person
    weaver = people(:weaver)

    get(:index, :person_id => weaver.to_param.to_s)
    
    assert_not_nil(assigns["results"], "Should assign results")
    assert_equal(weaver, assigns["person"], "Should assign person")
    assert_response(:success)
  end
  
  def test_find_person
    post(:find_person, :name => 'e', :ignore_id => people(:tonkin).id)    
    assert_response(:success)
    assert_template('admin/results/_people')
  end
  
  def test_find_person_one_result
    weaver = people(:weaver)

    post(:find_person, :name => weaver.name, :ignore_id => people(:tonkin).id)
    
    assert_response(:success)
    assert_template('admin/results/_person')
  end
  
  def test_find_person_no_results
    post(:find_person, :name => 'not a person in the database', :ignore_id => people(:tonkin).id)    
    assert_response(:success)
    assert_template('admin/results/_people')
  end
  
  def test_results
    weaver = people(:weaver)

    post(:results, :person_id => weaver.id)
    
    assert_response(:success)
    assert_template('admin/results/_person')
  end
  
  def test_move_result
    weaver = people(:weaver)
    tonkin = people(:tonkin)
    result = results(:tonkin_kings_valley)

    assert(tonkin.results.include?(result))
    assert(!weaver.results.include?(result))
    
    post(:move_result, :person_id => "person_#{weaver.id}", :id => "result_#{result.id}")
    
    assert(!tonkin.results(true).include?(result))
    assert(weaver.results(true).include?(result))
    assert_response(:success)
  end
end
