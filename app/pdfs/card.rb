class Card < Prawn::Document
  attr_reader :person
  
  def initialize(person)
    @person = person
  end
  
  def to_pdf
    top_margin = 36
    bottom_margin = 36
    left_margin = 14

    index = 0

    pointer = 742.8 - ((index % 3) * 268.4)
    text "#{RacingAssociation.current.effective_year} Member"
    # text "#{RacingAssociation.current.effective_year} Member", :align => :center, :size => 12, :absolute_left => 46, :absolute_right => 311.4
    # 
    # rectangle [31, 584.8 - ((index % 3) * 268.4)], 288, 162
    # stroke
    # 
    # pointer = 689.8 - ((index % 3) * 268.4)
    # font 'Helvetica-Bold'
    # text "#{RacingAssociation.current.effective_year} Membership Card", :align => :center, :size => 12, :absolute_left => 336.4, :absolute_right => 579.5
    # text(person.name || '', :align => :left, :size => 10, :absolute_left => 348, :absolute_right => 579.5)
    # 
    # previous_y = y
    # text("Road Cat: #{person.road_category}", :align => :left, :size => 9, :absolute_left => 348, :absolute_right => 579.5)
    # pointer = previous_y
    # text("Road # #{person.road_number}", :align => :left, :size => 9, :absolute_left => 458, :absolute_right => 579.5)
    # 
    # previous_y = y
    # text("CCX Cat: #{person.ccx_category}", :align => :left, :size => 9, :absolute_left => 348, :absolute_right => 579.5)
    # pointer = previous_y
    # text("Track Cat: #{person.track_category}", :align => :left, :size => 9, :absolute_left => 458, :absolute_right => 579.5)
    # 
    # previous_y = y
    # text("Mtn Cat: #{person.mtb_category}", :align => :left, :size => 9, :absolute_left => 348, :absolute_right => 579.5)
    # pointer = previous_y
    # text("Mtn # #{person.xc_number}", :align => :left, :size => 9, :absolute_left => 458, :absolute_right => 579.5)
    # 
    # previous_y = y
    # text("Downhill Cat: #{person.dh_category}", :align => :left, :size => 9, :absolute_left => 348, :absolute_right => 579.5)
    # pointer = previous_y
    # text("SS # #{person.singlespeed_number}", :align => :left, :size => 9, :absolute_left => 458, :absolute_right => 579.5)
    # 
    # text("Racing Age: #{person.racing_age}", :align => :left, :size => 9, :absolute_left => 348, :absolute_right => 579.5)
    # 
    # font 'Helvetica'
    # text "Membership expires 12/31/#{RacingAssociation.current.effective_year}", :align => :center, :size => 8, :absolute_left => 336.4, :absolute_right => 579.5
    # top_margin = 36
    # bottom_margin = 36
    # left_margin = 14
    render
  end
end
