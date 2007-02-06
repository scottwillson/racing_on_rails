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
# Worksheet -- Spreadsheet::ParseExcel -- 10.06.2003 -- hwyss@ywesee.com 

require 'parseexcel/olestorage'
require 'iconv'

module Spreadsheet
	module ParseExcel
		class Worksheet
			include Enumerable
			attr_accessor :default_row_height, :resolution, :v_resolution, :paper,
				:scale, :page_start, :fit_width, :fit_height, :header_margin,
				:footer_margin, :copies, :left_to_right, :no_pls, :no_color, :draft,
				:notes, :no_orient, :use_page, :landscape, :sheet_version, :sheet_type,
				:header, :footer, :page_fit
			class Cell
				attr_accessor :value, :kind, :numeric, :code, :book, :format_no,
					:format, :rich, :encoding, :annotation
				def initialize(params={:value=>'',:kind=>:blank,:numeric=>false})
					@encoding = 'UTF-16LE'
					params.each { |key, val|
						mthd = key.to_s + '='
						if(self.respond_to?(mthd))
							self.send(mthd, val)
						end
					}
				end
				def date
					datetime.date
				end
				def datetime
					date = @value.to_i
					time = @value.to_f - date
					#1. Calc Days
					year = 1900
					if (@book.flg_1904)
						year = 1904
						date += 1 #Start from Jan 1st
					end
					ydays = year_days(year)
					while (date > ydays)
						date -= ydays
						year += 1
						ydays = year_days(year)
					end
					month = 1
					1.upto(12) { |month|
						mdays = month_days(month, year)
						break if(date <= mdays)
						date -= mdays
					}
					#2. Calc Time
					day = date
					time += (0.0005 / 86400.0)
					time *= 24.0
					hour = time.to_i
					time -= hour
					time *= 60.0
					min = time.to_i
					time -= min
					time *= 60.0
					sec = time.to_i
					time -= sec
					time *= 1000.0
					msec = time.to_i
					OLE::DateTime.new(year,month,day,hour,min,sec,msec)
				end
				def to_i
					@value.to_i
				end
				def to_f
					@value.to_f
				end
				def to_s(target_encoding=nil)
					if(target_encoding)
						Iconv.new(target_encoding, @encoding).iconv(@value.to_s)
					else
						@value.to_s
					end
				end
				def type 
					@format.cell_type(self) if @format
				end
				private
				def month_days(month, year)
					if(year == 1900 && month == 2)
						29
					else
						OLE::DateTime::month_days(month, year)
					end
				end
				def year_days(year)
					(year == 1900) ? 366 : OLE::DateTime::year_days(year)
				end
			end
			class PkgString
				attr_reader :text, :unicode, :rich, :ext
				def initialize(text, unicode, rich, ext)
					@text, @unicode, @rich, @ext = text, unicode, rich, ext
				end
			end
			def initialize
				@cells = []
				@row_heights = []
			end
			def add_cell(row, col, cell)
				(@cells[row] ||= [])[col] ||= cell
				self.set_dimensions(row, col)
				@cells[row][col]
			end
			def cell(row, col)
				(@cells[row] ||= [])[col] ||= Cell.new
			end
			def each(skip=0, &block)
				@cells[skip..-1].each(&block)
			end
			def row(row)
				@cells[row] ||= []
			end
			def set_dimensions(row, scol, ecol=scol)
				@min_row = [row, @min_row || row].min
				@max_row = [row, @max_row || row].max
				@min_col = [scol, @min_col || scol].min
				@max_col = [ecol, @max_col || ecol].max
			end
			def set_row_height(row, height)
				@row_heights[row] = height
			end
		end
	end
end
