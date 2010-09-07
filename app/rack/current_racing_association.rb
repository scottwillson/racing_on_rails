require 'rack/utils'

module Rack
  class CurrentRacingAssociation
    def initialize(app)
      @app = app
    end

    def call(env)
      # RacingAssociation.current = RacingAssociation.first
      @app.call(env)
    end
  end
end
