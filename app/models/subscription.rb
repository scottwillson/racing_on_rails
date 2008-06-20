class Subscription
  
  attr_accessor :name, :email, :phone, :address, :city, :state, :zip, :comments
  attr_accessor :youth_programs, :racer_info, :race_results
  attr_accessor :volunteer, :sponsorship, :contribution
  
  def initialize(attributes = {})
    @name = attributes[:name]
    @email = attributes[:email]
    @phone = attributes[:phone]
    @address = attributes[:city]
    @state = attributes[:state]
    @zip = attributes[:zip]
    @comments = attributes[:comments]
    @youth_programs = attributes[:youth_programs]
    @racer_info = attributes[:racer_info]
    @race_results = attributes[:race_results]
    @volunteer = attributes[:volunteer]
    @sponsorship = attributes[:sponsorship]
    @contribution = attributes[:contribution]
  end
  
  def errors
    @errors ||= ActiveRecord::Errors.new(self)
  end
  
  def valid?
    !@name.blank? && !@email.blank?
  end
end