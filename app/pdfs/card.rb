class Card < Prawn::Document
  def initialize
    super(
      :top_margin => 52,
      :left_margin => 14
    )
  end

  def to_pdf(people, index = 0)
    Array.wrap(people).each do |person|
      if index > 0 && (index % 15 == 0)
        start_new_page
      end

      card_top = bounds.top_left.last - ((index % 15) / 3) * 144
      card_left_side = bounds.top_left.first + (index % 3) * 199
      font "Helvetica-Bold"
      fill_color "000000"
      self.font_size = 13
      draw_text person.name || "", :at => [ card_left_side, card_top ]
      self.font_size = 10
      draw_text "Categories:", :at => [ card_left_side, card_top - 12 ]

      draw_text "Road: #{person.road_category}", :at => [ card_left_side, card_top - 24 ]
      draw_text "MTB: #{Category.short_name(person.mtb_category)}", :at => [ card_left_side + 75, card_top - 24 ]

      draw_text "Track: #{person.track_category}", :at => [ card_left_side, card_top - 36 ]
      draw_text "DH: #{Category.short_name(person.dh_category)}", :at => [ card_left_side + 75, card_top - 36 ]

      draw_text "CCX: #{Category.short_name(person.ccx_category)}", :at => [ card_left_side, card_top - 48 ]
      draw_text "Age: #{person.racing_age}", :at => [ card_left_side + 75, card_top - 48 ]

      draw_text "Road # #{person.road_number}", :at => [ card_left_side, card_top - 60 ]

      draw_text "OBRA License # #{person.license}", :at => [ card_left_side, card_top - 72 ]

      fill_color "ffcc33"
      rectangle [ card_left_side + 164, card_top + 10 ], 20, 84
      fill

      fill_color "ffffff"
      self.font_size = 14
      draw_text "2", :at => [ card_left_side + 171, card_top - 10 ]
      draw_text "0", :at => [ card_left_side + 171, card_top - 27 ]
      draw_text "1", :at => [ card_left_side + 171, card_top - 44 ]
      draw_text "1", :at => [ card_left_side + 171, card_top - 61 ]
      
      index = index + 1
    end
    
    render
  end
end
