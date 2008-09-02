require "pdf/writer"

module ActionView
  module TemplateHandlers
    class PDFWriter < TemplateHandler
      include Compilable

      def self.line_offset
        2
      end

      def compile(template)
        content_type_handler = (@view.send!(:controller).respond_to?(:response) ? "controller.response" : "controller")
        "#{content_type_handler}.content_type ||= Mime::PDF\n" +
        "pdf = PDF::Writer.new(:paper => (@paper || 'LETTER'))\n" +
        template.source +
        "\npdf.render\n"
      end

      def cache_fragment(block, name = {}, options = nil)
        @view.fragment_for(block, name, options) do
          eval('pdf.render', block.binding)
        end
      end
    end
  end
end
