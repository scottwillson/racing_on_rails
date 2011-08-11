require 'newrelic_rpm'
NewRelic::Agent.manual_start(:dispatcher => :unicorn)
