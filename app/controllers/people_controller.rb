class PeopleController < ApplicationController
  def index
    @people = []
    @name = params['name'] || ''
    @name.strip!
    if @name.blank?
      @people = People.paginate :page => params[:page], :order => 'last_name asc, first_name asc'
    else
      @people = People.find_all_by_name_like(@name)
      @people = @people.paginate(:page => params[:page])
      @name = ''
    end
  end
end
