class Api::PersonController < ApplicationController
  def index
    people = Person.all
    respond_to do |format|
      format.xml {
        render :xml => people.to_xml(
          :include => [ :aliases, :events, :race_numbers, :results, :team ]
        )
      }
    end
  end
end
