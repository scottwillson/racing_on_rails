# frozen_string_literal: true

# What appear to be duplicate finds are actually existence tests.
# Many methods to handle old URLs that search engines still hit. Will be removed.
module Calculations
  class ResultsController < ApplicationController
    def index
    end
  end
end
