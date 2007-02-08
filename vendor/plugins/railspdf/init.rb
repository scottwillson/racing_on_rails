# Include hook code here
require "railspdf"  #  Made lowercase so will work in linux  -- tomw
#require "ActionView"

ActionView::Base.register_template_handler 'rpdf', RailsPDF::PDFRender