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
# Format -- Spreadsheet::ParseExcel -- 10.06.2003 -- hwyss@ywesee.com 

module Spreadsheet
	module ParseExcel
		class Format
			@@fmt_strs = {
				0x00 => '@',
				0x01 => '0',
				0x02 => '0.00',
				0x03 => '#,##0',
				0x04 => '#,##0.00',
				0x05 => '($#,##0_);($#,##0)',
				0x06 => '($#,##0_);[RED]($#,##0)',
				0x07 => '($#,##0.00_);($#,##0.00_)',
				0x08 => '($#,##0.00_);[RED]($#,##0.00_)',
				0x09 => '0%',
				0x0A => '0.00%',
				0x0B => '0.00E+00',
				0x0C => '# ?/?',
				0x0D => '# ??/??',
				0x0E => 'm-d-yy',
				0x0F => 'd-mmm-yy',
				0x10 => 'd-mmm',
				0x11 => 'mmm-yy',
				0x12 => 'h:mm AM/PM',
				0x13 => 'h:mm:ss AM/PM',
				0x14 => 'h:mm',
				0x15 => 'h:mm:ss',
				0x16 => 'm-d-yy h:mm',
		#0x17-0x24 -- Differs in Natinal
				0x25 => '(#,##0_);(#,##0)',
				0x26 => '(#,##0_);[RED](#,##0)',
				0x27 => '(#,##0.00);(#,##0.00)',
				0x28 => '(#,##0.00);[RED](#,##0.00)',
				0x29 => '_(*#,##0_);_(*(#,##0);_(*"-"_);_(@_)',
				0x2A => '_($*#,##0_);_($*(#,##0);_(*"-"_);_(@_)',
				0x2B => '_(*#,##0.00_);_(*(#,##0.00);_(*"-"??_);_(@_)',
				0x2C => '_($*#,##0.00_);_($*(#,##0.00);_(*"-"??_);_(@_)',
				0x2D => 'mm:ss',
				0x2E => '[h]:mm:ss',
				0x2F => 'mm:ss.0',
				0x30 => '##0.0E+0',
				0x31 => '@',
			}
			attr_accessor :font_no, :fmt_idx, :lock, :hidden, :style, :key_123
			attr_accessor :align_h, :wrap, :align_v, :just_last, :rotate, :indent
			attr_accessor :shrink, :merge, :read_dir
			attr_accessor :border_style, :border_color, :border_diag, :fill
			def initialize(params={})
				params.each { |key, val|
					mthd = key.to_s + '='
					if(self.respond_to?(mthd))
						self.send(mthd, val)
					end
				}
			end
			def add_text_format(idx, fmt_str)
				@@fmt_strs.store(idx, fmt_str)
			end
			def cell_type(cell)
				if(cell.numeric)
					#p @fmt_idx, @@fmt_strs[@fmt_idx]
					if([0x0E..0x16, 0x2D..0x2F].any? { |range| range.include?(@fmt_idx.to_i) })
						:date
					elsif((fmt = @@fmt_strs[@fmt_idx]) && /(dd|mm|yy|hh|ss)/i.match(fmt))
						:date
					else
						:numeric
					end
				else
					:text
				end
			end
			def text_format(str, code=:_native_)
				(code == :_native_) ? str : str.unpack('n*').pack('C*')
			end
		end
	end
end
