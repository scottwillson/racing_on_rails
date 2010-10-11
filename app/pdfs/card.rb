class Card  
  def self.to_pdf(person)
    Prawn::Document.generate("hello_foo.pdf") do
      top_margin = 36
      bottom_margin = 36
      left_margin = 14

      index = 0

      pointer = 742.8 - ((index % 3) * 268.4)
      text "#{RacingAssociation.current.effective_year} Member"
    end
    # card_top = (pdf.page_height - pdf.top_margin) - (((index % 15) / 3) * 144)
    # pdf.y = card_top
    # card_left_side = pdf.left_margin + ((index % 3) * 199)
    # 
    # pdf.select_font 'Helvetica-Bold'
    # pdf.fill_color Color::RGB.new(0, 0, 0)
    # pdf.text person.name || '', :font_size => 13, :absolute_left => card_left_side
    # pdf.font_size = 10
    # pdf.text 'Categories:', :absolute_left => card_left_side
    # 
    # previous_y = pdf.y
    # pdf.text("Road: #{person.road_category}", :absolute_left => card_left_side)
    # pdf.pointer = previous_y
    # pdf.text("MTB: #{abbreviate_category(person.mtb_category)}", :absolute_left => card_left_side + 75)
    # 
    # previous_y = pdf.y
    # pdf.text("Track: #{person.track_category}", :absolute_left => card_left_side)
    # pdf.pointer = previous_y
    # pdf.text("DH: #{abbreviate_category(person.dh_category)}", :absolute_left => card_left_side + 75)
    # 
    # previous_y = pdf.y
    # pdf.text("CCX: #{abbreviate_category(person.ccx_category)}", :absolute_left => card_left_side)
    # pdf.pointer = previous_y
    # pdf.text("Age: #{person.racing_age}", :absolute_left => card_left_side + 75)
    # 
    # previous_y = pdf.y
    # pdf.text("Road # #{person.road_number}", :absolute_left => card_left_side)
    # pdf.text("OBRA License # #{person.license}", :absolute_left => card_left_side)
    # pdf.pointer = previous_y
    # pdf.text("CX Age: #{person.cyclocross_racing_age}", :absolute_left => card_left_side + 75)
    # 
    # pdf.fill_color Color::RGB::Pink
    # pdf.rectangle(card_left_side + 164, card_top - 90, 20, 84).fill
    # 
    # pdf.fill_color Color::RGB::Black
    # pdf.font_size = 14
    # pdf.y = card_top - 12
    # pdf.text('2', :justification => :center, :absolute_left => card_left_side + 164, :absolute_right => card_left_side + 184)
    # pdf.text('0', :justification => :center, :absolute_left => card_left_side + 164, :absolute_right => card_left_side + 184)
    # pdf.text('1', :justification => :center, :absolute_left => card_left_side + 164, :absolute_right => card_left_side + 184)
    # pdf.text('0', :justification => :center, :absolute_left => card_left_side + 164, :absolute_right => card_left_side + 184)
  end
end
