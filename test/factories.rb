FactoryGirl.define do
  factory :person_alias, :class => Alias do
    sequence(:name) { |n| "Person Alias #{n}" }
    person
  end

  factory :team_alias, :class => Alias do
    sequence(:name) { |n| "Team Alias #{n}" }
    team
  end
  
  factory :article
  
  factory :article_category

  factory :category do
    sequence(:name) { |n| "Category #{n}" }
  end
  
  factory :discipline do
    bar true
    name "Road"
    numbers true

    factory :cyclocross_discipline do
      name "Cyclocross"
      after(:create) { |d| 
        d.discipline_aliases.create!(:alias => "ccx")
        d.discipline_aliases.create!(:alias => "cx")
      }
    end

    factory :mtb_discipline do
      name "Mountain Bike"
      after(:create) { |d| d.discipline_aliases.create!(:alias => "mtb") }
    end
  end
  
  factory :discipline_alias do
    sequence(:alias) { |n| "#{n}" }
    discipline
  end
  
  factory :event, :class => "SingleDayEvent" do
    promoter :factory => :person
    factory :multi_day_event, :class => "MultiDayEvent"
    factory :series, :class => "Series"
    factory :weekly_series, :class => "WeeklySeries"
    
    factory :series_event do
      parent :factory => :series
    end

    factory :stage_race, :class => "MultiDayEvent" do |parent|
      date Time.zone.local(2005, 7, 11)
      children { |e| [ 
        e.association(:event, :date => Time.zone.local(2005, 7, 11), :parent_id => e.id),  
        e.association(:event, :date => Time.zone.local(2005, 7, 12), :parent_id => e.id), 
        e.association(:event, :date => Time.zone.local(2005, 7, 13), :parent_id => e.id) 
      ] }
    end
    
    factory :weekly_series_event do
      parent :factory => :weekly_series
    end
    
    factory :time_trial_event do
      discipline "Time Trial"
    end
  end
  
  factory :mailing_list do
    sequence(:name, "a") { |n| "obra_#{n}" }    
    sequence(:friendly_name, "a") { |n| "OBRA Chat #{n}" }
    sequence(:subject_line_prefix, "a") { |n| "OBRA Chat #{n}" }
  end
  
  factory :number_issuer do
    name "CBRA"
  end
  
  factory :page do
    body "<p>This is a plain page</p>"
    path "plain"
    slug "plain"
    title "Plain"
    updated_at Time.zone.local(2007)
    created_at Time.zone.local(2007)
    updated_by :factory => :person
  end
  
  factory :person do
    first_name "Ryan"
    sequence(:last_name) { |n| "Weaver#{n}" }
    name { "#{first_name} #{last_name}".strip }
    member_from { Time.zone.local(2000).beginning_of_year.to_date }
    member_to   { Time.zone.now.end_of_year.to_date }

    factory :past_member do
      first_name "Kevin"
      last_name "Condron"
      member_to Time.zone.local(2003).beginning_of_year
      name "Kevin Condron"
    end
    
    
    factory :person_with_login do
      sequence(:login) { |n| "person#{n}@example.com" }
      sequence(:email) { |n| "person#{n}@example.com" }
      password_salt { Authlogic::Random.hex_token }
      crypted_password { Authlogic::CryptoProviders::Sha512.encrypt("secret" + password_salt) }
      persistence_token { Authlogic::Random.hex_token }
      single_access_token { Authlogic::Random.friendly_token }
      perishable_token { Authlogic::Random.friendly_token }
      
      factory :administrator do
        first_name "Candi"
        last_name "Murray"
        roles { |r| [ r.association(:role) ] }
        login "admin@example.com"
        email "admin@example.com"
        home_phone "(503) 555-1212"
      end

      factory :promoter do
        events { |p| [ p.association(:event, :promoter_id => p.id) ] }
      end
    end
  end

  factory :photo do
    caption "Photo Caption"
    image { File.new("#{Rails.root}/test/fixtures/photo.jpg") }
    title "Photo title"
    height 100
    width 137
  end

  factory :post do
    mailing_list
    subject "[OBRA Chat] Foo"
    from_email_address "foo@bar.net"
    from_name "Foo"
    body "Test message"
    date { Time.zone.today }
  end

  factory :race do
    category
    event
    
    factory :time_trial_race do
      association :event, :factory => :time_trial_event
    end
    
    factory :weekly_series_race do
      association :event, :factory => :weekly_series_event
    end
  end
  
  factory :race_number do
    discipline
    number_issuer
    person
    sequence :value, "100"
  end

  factory :role do
    name "Administrator"
  end
  
  factory :result do
    sequence :place
    race
    person
    team
    
    factory :time_trial_result do
      time 1800
      association :race, :factory => :time_trial_race
    end
    
    factory :weekly_series_event_result do
      association :race, :factory => :weekly_series_race
    end
  end  
  
  factory :team do
    member true
    sequence(:name) { |n| "Team #{n}" }
  end
  
  factory :velodrome do
    sequence(:name) { |n| "Velodrome #{n}" }    
  end
end
