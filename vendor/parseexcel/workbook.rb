#!/usr/bin/env ruby
#
#	Spreadsheet::ParseExcel -- Extract Data from an Excel File
#	Copyright (C) 2003 ywesee -- intellectual capital connected
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#	ywesee - intellectual capital connected, Winterthurerstrasse 52, CH-8006 Zürich, Switzerland
#	hwyss@ywesee.com
#
# Workbook -- Spreadsheet::ParseExcel -- 10.06.2003 -- hwyss@ywesee.com 

require 'parseexcel/worksheet'

module Spreadsheet
	module ParseExcel
		class Annotation < String
			attr_accessor :author
		end
		class Workbook
			attr_accessor :biffversion, :version, :flg_1904
			attr_writer :format
			def initialize
				@worksheets = []
				@pkg_strs = []
				@annotations = []
				@formats = []
			end
			def add_annotation(pkg_str)
				@annotations.push(pkg_str)
			end
			def add_text_format(idx, fmt_str)
				@format.add_text_format(idx, fmt_str)
			end
			def add_cell_format(format)
				@formats.push(format)
			end
			def add_pkg_str(pkg_str)
				@pkg_strs.push(pkg_str)
			end
			def annotation(idx)
				@annotations.at(idx)
			end
			def format(idx=nil)
				(idx.nil?) ? @format : @formats.at(idx)
			end
			def pkg_str(idx)
				@pkg_strs.at(idx)
			end
			def sheet_count
				@worksheets.size
			end
			def worksheet(idx)
				@worksheets[idx] ||= Worksheet.new
			end
		end
	end
end
