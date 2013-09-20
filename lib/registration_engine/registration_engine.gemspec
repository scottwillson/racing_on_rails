$:.push File.expand_path("../lib", __FILE__)

require "registration_engine/version"

Gem::Specification.new do |s|
  s.name        = "registration_engine"
  s.version     = RegistrationEngine::VERSION
  s.authors     = [ "Scott Willson" ]
  s.email       = [ "scott.willson@gmail.com" ]
  s.homepage    = "http://rocketsurgeryllc.com"
  s.summary     = "Event registration"
  s.description = "Racing on Rails event registration"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "activemerchant"
end
