module Competitions
  class OregonCupController < ApplicationController
    def index
      @oregon_cup = OregonCup.find_for_year(@year) || OregonCup.new
    end
  end
end
