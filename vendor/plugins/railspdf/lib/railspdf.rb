# Railspdf
require 'pdf/writer'
require 'pdf/simpletable'    #Added so that tables can be used  -- tomw

module RailsPDF
  # this code comes from http://wiki.rubyonrails.com/rails/pages/HowtoGeneratePDFs 	
  # Made PDFRender a subclass of ActionView so ActionView helpers can be used in .rpdf documents -- tomw
  class PDFRender < ActionView::Base
    # PAPER = 'A4'  Removed so that paper size can be set in controller  -- tomw
  	include ApplicationHelper

  	def initialize(action_view)
      @action_view = action_view
  	end

    def render(template, local_assigns = {})
    	#get the instance variables setup	    	
   		@action_view.controller.instance_variables.each do |v|
        instance_variable_set(v, @action_view.controller.instance_variable_get(v))
      end

      #keep ie happy
      if @action_view.controller.request.env['HTTP_USER_AGENT'] =~ /msie/i
        @action_view.controller.headers['Pragma'] ||= ''
        @action_view.controller.headers['Cache-Control'] ||= ''
      else
        @action_view.controller.headers['Pragma'] ||= 'no-cache'
        @action_view.controller.headers['Cache-Control'] ||= 'no-cache, must-revalidate'
      end
 		
  		@action_view.controller.headers["Content-Type"] ||= 'application/pdf'
    	if @rails_pdf_name
    		@action_view.controller.headers["Content-Disposition"] ||= 'attachment; filename="' + @rails_pdf_name + '"'
    	elsif @rails_pdf_inline
    		#set no headers
    	else #rails_pdf_inline was set to false.  set filename = controller name
    		 #since we weren't provided a custom name
    		@action_view.controller.headers["Content-Disposition"] ||= 'attachment; filename="' + @action_view.controller.controller_name + '.pdf' + '"'
    	end

      # Added @landscape and @paper variables so controller can set landscape mode and paper size -- tomw
      if @landscape
     		pdf = PDF::Writer.new( :paper => (@paper || 'LETTER'), :orientation => :landscape )
      else
     		pdf = PDF::Writer.new( :paper => (@paper || 'LETTER') )
      end
    	pdf.compressed = true if RAILS_ENV != 'development'
      eval template, nil, "#{@action_view.base_path}/#{@action_view.first_render}.#{@action_view.pick_template_extension(@action_view.first_render)}" 
  		pdf.render
    end
  end
end