class PeopleController < ApplicationController
  def index
    @people = []
    @name = params['name'] || ''
    @name.strip!
    if @name.blank?
      @people = Person.paginate :page => params[:page], :order => 'last_name asc, first_name asc'
    else
      @people = Person.find_all_by_name_like(@name)
      @people = @people.paginate(:page => params[:page])
      @name = ''
    end
  end
end
