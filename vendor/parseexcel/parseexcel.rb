#!/usr/bin/env ruby
# ParseExcel -- Spreadsheet -- 03.06.2003 -- hwyss@ywesee.com 

require 'parseexcel/olestorage'
require 'parseexcel/parser'

module Spreadsheet
	module ParseExcel
		def parse(source, params={})
			Parser.new(params).parse(source)
		end
		module_function :parse
	end
end
