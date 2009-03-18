require "test_helper"

class Admin::ResultsControllerTest < ActionController::TestCase
  def setup
    super
    @request.session[:user_id] = users(:administrator).id    
  end
  
  def test_update_no_team
    weaver_jack_frost = results(:weaver_jack_frost)
    weaver_jack_frost.team = nil
    weaver_jack_frost.save!

    team_name = ''
        
    post(:set_result_team_name, 
        :id => weaver_jack_frost.to_param,
        :value => team_name,
        :editorId => "result_#{weaver_jack_frost.id}_team_name"
    )
    assert_response(:success)

    weaver_jack_frost.reload
    assert_nil(weaver_jack_frost.team(true), 'team')
  end
  
  def test_update_no_team_to_existing
    weaver_jack_frost = results(:weaver_jack_frost)
    weaver_jack_frost.team = nil
    weaver_jack_frost.save!
    
    post(:set_result_team_name, 
        :id => weaver_jack_frost.to_param,
        :value => teams(:vanilla).name,
        :editorId => "result_#{weaver_jack_frost.id}_team_name"
    )
    assert_response(:success)

    weaver_jack_frost.reload
    assert_equal(teams(:vanilla), weaver_jack_frost.team(true), 'team')
  end
  
  def test_update_no_team_to_new
    weaver_jack_frost = results(:weaver_jack_frost)
    weaver_jack_frost.team = nil
    weaver_jack_frost.save!

    post(:set_result_team_name, 
        :id => weaver_jack_frost.to_param,
        :value => "Team Vanilla",
        :editorId => "result_#{weaver_jack_frost.id}_team_name"
    )
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
    
    post(:set_result_team_name, 
        :id => weaver_jack_frost.to_param,
        :value => team_name,
        :editorId => "result_#{weaver_jack_frost.id}_team_name"
    )
    assert_response(:success)

    weaver_jack_frost.reload
    assert_equal(teams(:gentle_lovers), weaver_jack_frost.team(true), 'team')
  end
  
  def test_update_to_no_team
    weaver_jack_frost = results(:weaver_jack_frost)

    team_name = ''
    
    post(:set_result_team_name, 
        :id => weaver_jack_frost.to_param,
        :value => team_name,
        :editorId => "result_#{weaver_jack_frost.id}_team_name"
    )
    assert_response(:success)

    weaver_jack_frost.reload
    assert_nil(weaver_jack_frost.team(true), 'team')
  end
  
  def test_update_to_existing_team
    weaver_jack_frost = results(:weaver_jack_frost)

    team_name = 'Vanilla'
    
    post(:set_result_team_name, 
        :id => weaver_jack_frost.to_param,
        :value => team_name,
        :editorId => "result_#{weaver_jack_frost.id}_team_name"
    )
    assert_response(:success)

    weaver_jack_frost.reload
    assert_equal(teams(:vanilla), weaver_jack_frost.team(true), 'team')
  end
  
  def test_update_to_new_team
    weaver_jack_frost = results(:weaver_jack_frost)

    team_name = 'Astana'
    
    post(:set_result_team_name, 
        :id => weaver_jack_frost.to_param,
        :value => team_name,
        :editorId => "result_#{weaver_jack_frost.id}_team_name"
    )
    assert_response(:success)

    weaver_jack_frost.reload
    assert_equal(team_name, weaver_jack_frost.team(true).name, 'team name')
  end
  
  def test_update_to_team_alias
    weaver_jack_frost = results(:weaver_jack_frost)

    team_name = 'Gentile Lovers'
    
    post(:set_result_team_name, 
        :id => weaver_jack_frost.to_param,
        :value => team_name,
        :editorId => "result_#{weaver_jack_frost.id}_team_name"
    )
    assert_response(:success)

    weaver_jack_frost.reload
    assert_equal(teams(:gentle_lovers), weaver_jack_frost.team(true), 'team')
  end
  
  def test_set_result_points
    assert(racers(:weaver).aliases(true).empty?)
    weaver_jack_frost = results(:weaver_jack_frost)
    assert_equal(0, weaver_jack_frost.points, 'points')

    post(:set_result_points, 
        :id => weaver_jack_frost.to_param,
        :value => "12",
        :editorId => "result_#{weaver_jack_frost.id}_points"
    )
    assert_response(:success)

    weaver_jack_frost.reload
    assert_equal(12, weaver_jack_frost.points, 'points')
  end
  
  def test_update_no_racer
    weaver_jack_frost = results(:weaver_jack_frost)
    weaver_jack_frost.racer = nil
    weaver_jack_frost.save!

    original_team_name = weaver_jack_frost.team_name
    
    post(:set_result_team_name, 
        :id => weaver_jack_frost.to_param,
        :value => original_team_name,
        :editorId => "result_#{weaver_jack_frost.id}_team_name"
    )
    assert_response(:success)

    weaver_jack_frost.reload
    assert_equal("", weaver_jack_frost.first_name, 'first_name')
    assert_equal("", weaver_jack_frost.last_name, 'last_name')
    assert_equal(original_team_name, weaver_jack_frost.team_name, 'team_name')
    assert_nil(weaver_jack_frost.racer(true), 'racer')
  end
  
  def test_update_no_racer_to_existing
    weaver_jack_frost = results(:weaver_jack_frost)
    weaver_jack_frost.racer = nil
    weaver_jack_frost.save!

    original_team_name = weaver_jack_frost.team_name
    
    post(:set_result_name,
        :id => weaver_jack_frost.to_param,
        :value => "Erik Tonkin",
        :editorId => "result_#{weaver_jack_frost.id}_name"
    )
    assert_response(:success)
    
    weaver_jack_frost.reload
    assert_equal("Erik Tonkin", weaver_jack_frost.name, 'name')
    assert_equal(original_team_name, weaver_jack_frost.team_name, 'team_name')
    assert_equal(racers(:tonkin), weaver_jack_frost.racer(true), 'racer')
    assert_equal(1, racers(:tonkin).aliases.size)
  end
  
  def test_update_no_racer_to_alias
    weaver_jack_frost = results(:weaver_jack_frost)
    weaver_jack_frost.racer = nil
    weaver_jack_frost.save!

    original_team_name = weaver_jack_frost.team_name
    
    post(:set_result_name,
        :id => weaver_jack_frost.to_param,
        :value => "Eric Tonkin",
        :editorId => "result_#{weaver_jack_frost.id}_racer_name"
    )
    assert_response(:success)

    weaver_jack_frost.reload
    assert_equal('Erik Tonkin', weaver_jack_frost.name, 'name')
    assert_equal(original_team_name, weaver_jack_frost.team_name, 'team_name')
    assert_equal(racers(:tonkin), weaver_jack_frost.racer(true), 'racer')
    assert_equal(1, racers(:tonkin).aliases.size)
  end
  
  def test_update_to_no_racer
    weaver_jack_frost = results(:weaver_jack_frost)

    original_team_name = weaver_jack_frost.team_name
    
    post(:set_result_name, 
        :id => weaver_jack_frost.to_param,
        :value => "",
        :editorId => "result_#{weaver_jack_frost.id}_name"
    )
    assert_response(:success)

    weaver_jack_frost.reload
    assert_equal("", weaver_jack_frost.first_name, 'first_name')
    assert_equal("", weaver_jack_frost.last_name, 'last_name')
    assert_equal(original_team_name, weaver_jack_frost.team_name, 'team_name')
    assert_nil(weaver_jack_frost.racer(true), 'racer')
  end
  
  def test_update_to_different_racer
    assert_equal(1, racers(:tonkin).aliases.size)
    weaver_jack_frost = results(:weaver_jack_frost)

    original_team_name = weaver_jack_frost.team_name
    
    post(:set_result_name, 
        :id => weaver_jack_frost.to_param,
        :value => "Erik Tonkin",
        :editorId => "result_#{weaver_jack_frost.id}_name"
    )
    assert_response(:success)

    weaver_jack_frost.reload
    assert_equal("Erik", weaver_jack_frost.first_name, 'first_name')
    assert_equal("Tonkin", weaver_jack_frost.last_name, 'last_name')
    assert_equal(original_team_name, weaver_jack_frost.team_name, 'team_name')
    assert_equal(racers(:tonkin), weaver_jack_frost.racer(true), 'racer')
    assert_equal(1, racers(:tonkin).aliases.size)
  end
  
  def test_update_to_alias
    weaver_jack_frost = results(:weaver_jack_frost)

    first_name = 'Eric'
    last_name = 'Tonkin'
    original_team_name = weaver_jack_frost.team_name
    
    post(:set_result_name, 
        :id => weaver_jack_frost.to_param,
        :value => "Eric Tonkin",
        :editorId => "result_#{weaver_jack_frost.id}_name"
    )
    assert_response(:success)
    
    weaver_jack_frost.reload
    assert_equal('Erik', weaver_jack_frost.first_name, 'first_name')
    assert_equal(last_name, weaver_jack_frost.last_name, 'last_name')
    assert_equal(original_team_name, weaver_jack_frost.team_name, 'team_name')
    assert_equal(racers(:tonkin), weaver_jack_frost.racer(true), 'racer')
    assert_equal(1, racers(:tonkin).aliases.size)
  end
  
  def test_racer
    weaver = racers(:weaver)
    opts = {:controller => "admin/results", :action => "racer", :id => weaver.to_param.to_s}
    assert_routing("/admin/results/racer/#{weaver.to_param}", opts)

    get(:racer, :id => weaver.to_param.to_s)
    
    assert_not_nil(assigns["results"], "Should assign results")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_response(:success)
  end
  
  def test_find_racer
    post(:find_racer, :name => 'e', :ignore_id => racers(:tonkin).id)    
    assert_response(:success)
    assert_template('admin/results/_racers')
  end
  
  def test_find_racer_one_result
    weaver = racers(:weaver)

    post(:find_racer, :name => weaver.name, :ignore_id => racers(:tonkin).id)
    
    assert_response(:success)
    assert_template('admin/results/_racer')
  end
  
  def test_find_racer_no_results
    post(:find_racer, :name => 'not a racer in the database', :ignore_id => racers(:tonkin).id)    
    assert_response(:success)
    assert_template('admin/results/_racers')
  end
  
  def test_results
    weaver = racers(:weaver)

    post(:results, :id => weaver.id)
    
    assert_response(:success)
    assert_template('admin/results/_racer')
  end
  
  def test_move_result
    weaver = racers(:weaver)
    tonkin = racers(:tonkin)
    result = results(:tonkin_kings_valley)

    assert(tonkin.results.include?(result))
    assert(!weaver.results.include?(result))
    
    post(:move_result, :racer_id => "racer_#{weaver.id}", :id => "result_#{result.id}")
    
    assert(!tonkin.results(true).include?(result))
    assert(weaver.results(true).include?(result))
    assert_response(:success)
  end
end
