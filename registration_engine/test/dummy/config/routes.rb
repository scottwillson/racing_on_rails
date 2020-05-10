Rails.application.routes.draw do
  mount RegistrationEngine::Engine => "/registration_engine"
end
