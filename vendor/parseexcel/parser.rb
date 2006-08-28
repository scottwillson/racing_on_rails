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
# Parser -- Spreadsheet::ParseExcel -- 10.06.2003 -- hwyss@ywesee.com 

require 'parseexcel/olestorage'
require 'parseexcel/workbook'
require 'parseexcel/worksheet'
require 'parseexcel/format'

module Spreadsheet
	module ParseExcel
		class Parser
			attr_reader :bigendian
			CONTINUE = 0x03C
			SST = 0x0FC
			EVENT_TABLE = {
				#Develpers' Kit P291
				0x14    => :header,            # Header
				0x15    => :footer,            # Footer
=begin
				0x18    => :name,              # NAME(?)
				0x1A    => :v_page_break,      # Veritical Page Break
				0x1B    => :h_page_break,      # Horizontal Page Break
=end
				0x22    => :flg_1904,          # 1904 Flag
=begin
				0x26    => :margin,            # Left Mergin
				0x27    => :margin,            # Right Mergin
				0x28    => :margin,            # Top Mergin
				0x29    => :margin,            # Bottom Mergin
				0x2A    => :print_headers,     # Print Headers
				0x2B    => :print_gridlines,   # Print Gridlines
=end
				CONTINUE=> :continue,          # Continue
				0x43    => :xf,                # ExTended Format(?)
=begin
				#Develpers' Kit P292
				0x55		=> :def_col_width,		 # Consider
				0x5C    => :write_access,      # WRITEACCESS
				0x7D    => :col_info,          # Colinfo
=end
				0x7E    => :rk,                # RK
				0x81    => :ws_bool,           # WSBOOL
=begin
				0x83    => :h_center,          # HCENTER
				0x84    => :v_center,          # VCENTER
				0x85    => :bound_sheet,       # BoundSheet

				0x92    => :palette,           # Palette, fgp

				0x99    => :standard_width,    # Standard Col
				#Develpers' Kit P293
=end
				0xA1    => :setup,             # SETUP
				0xBD    => :mul_rk,            # MULRK
				0xBE    => :mul_blank,         # MULBLANK
				0xD6    => :rstring,           # RString
				#Develpers' Kit P294
				0xe0    => :xf,                # ExTended Format
=begin
				0xE5    => :merge_area,        # MergeArea (Not Documented)
=end
				SST     => :sst,               # Shared String Table
				0xFD    => :label_sst,         # Label SST
				#Develpers' Kit P295
				0x201   => :blank,             # Blank

				0x202   => :integer,           # Integer(Not Documented)
				0x203   => :number,            # Number
				0x204   => :label ,            # Label
				0x205   => :bool_err,          # BoolErr
				0x207   => :string,            # STRING
				0x208   => :row,               # RowData
				0x221   => :array,             # Array (Consider)
				0x225   => :default_row_height,# Consider
=begin
				0x31    => :font,              # Font
				0x231   => :font,              # Font

=end
				0x27E   => :rk,                # RK
				0x41E   => :format,            # Format
				0x06    => :formula,           # Formula
				0x406   => :formula,           # Formula
				0x09    => :bof,               # BOF(BIFF2)
				0x209   => :bof,               # BOF(BIFF3)
				0x409   => :bof,               # BOF(BIFF4)
				0x809   => :bof,               # BOF(BIFF5-8)
			}
      UNIMPLEMENTED = {
        #Develpers' Kit P291
        0x18    => :name,              # NAME(?)
        0x1A    => :v_page_break,      # Veritical Page Break
        0x1B    => :h_page_break,      # Horizontal Page Break
        0x26    => :margin,            # Left Mergin
        0x27    => :margin,            # Right Mergin
        0x28    => :margin,            # Top Mergin
        0x29    => :margin,            # Bottom Mergin
        0x2A    => :print_headers,     # Print Headers
        0x2B    => :print_gridlines,   # Print Gridlines
        0x42    => :codepage,          # BIFF_CODEPAGE
        #Develpers' Kit P292
        0x55    => :def_col_width,     # Consider
        0x5C    => :write_access,      # WRITEACCESS
        0x7D    => :col_info,          # Colinfo
        0x81    => :ws_bool,           # WSBOOL
        0x83    => :h_center,          # HCENTER
        0x84    => :v_center,          # VCENTER
        0x85    => :bound_sheet,       # BoundSheet

        0x92    => :palette,           # Palette, fgp

        0x99    => :standard_width,    # Standard Col
        #Develpers' Kit P293
        0xc1    => :add_menu,          # BIFF_ADDMENU
        0xe1    => :interface_hdr,     # BIFF_INTERFACEHDR
        0xe2    => :interface_end,     # BIFF_INTERFACEEND
        0xE5    => :merge_area,        # MergeArea (Not Documented)
        0x31    => :font,              # Font
        0x161   => :dsf,               # BIFF_DSF
        0x231   => :font,              # Font
        0x293   => :style,             # BIFF_STYLE
      }
			def initialize(params={})
				#0. Check ENDIAN(Little: Intel etc. BIG: Sparc etc)
				@bigendian = params.fetch(:bigendian) { 
					[2].pack('L').unpack('H8').first != '02000000'
				}
				@buff = ''
				#1.2 Set Event Handler
				set_event_handlers(params[:event_handlers] || EVENT_TABLE)
				if(params[:add_handlers].is_a? Hash)
					params[:add_handlers].each { |key, value|
						set_event_handler(key, value)
					}
				end
=begin	
				#Experimental
				$_CellHandler = $hParam{CellHandler} if($hParam{CellHandler});
				$_NotSetCell  = $hParam{NotSetCell};
				$_Object      = $hParam{Object};
=end
			end
			def parse(source, format=nil)
				begin
					#0. New $oBook
					@workbook = Workbook.new
					#1.Get content
					@ole = OLE::Storage.new(source)
					biff = @ole.search_pps(
						[
							OLE.asc2ucs('Book'),
							OLE.asc2ucs('Workbook'),
						], true).first.data

					#2. Ready for format
					@workbook.format = (format || Format.new)
					
					#3. Parse content
					pos = 0
					work = biff[pos, 4]
					pos += 4
					ef_flag = false
					blen = biff.length
					while(pos <= blen)
						op, len = work.unpack('v2')
						#puts "*"*33
						#puts sprintf("0x%03x %i ->%s<-", op, len, work.inspect[0,200])
						#p "#{biff.length} / #{pos}"
						#p work, op, len
						if(len)
							work = biff[pos, len]
							pos += len
						end
						#Check EF, EOF
						if(op == 0xEF) #EF
							ef_flag = op
						elsif(op == 0x0A) #EOF
							ef_flag = nil
						end
						#puts "ef_flag: =>#{ef_flag}<="
						unless(ef_flag)	
							#1. Formula String, but not string (0x207)
							if(!@prev_pos.nil? && @proc_table.include?(op) && op != 0x207)
								row, col, fmt = @prev_pos
								@prev_pos = nil
								params = {
									:kind				=>	:formula_string,
									:value			=>	'',
									:format_no	=>	fmt,
									:numeric		=>	false,
								}
								cell_factory(row, col, params)
							end
							if(prc = @proc_table[op])
								#puts sprintf("%s 0x%03x %i ->%s<-", prc, op, len, work.inspect[0,30])
								prc.call(op,len,work)
							elsif(prc = UNIMPLEMENTED[op])
								#warn sprintf("opcode not implemented: 0x%03x/%s", op.to_i, prc.to_s)
							else
								#warn sprintf("unknown opcode: 0x%03x (%s)", op.to_i, work.inspect[0,30])
							end
							(@prev_prc = op) unless(op == CONTINUE) 
						end
						work = biff[pos, 4] if((pos+4) <= blen)
						pos += 4
						if(@parse_abort)
							return @workbook
						end
					end
					@workbook
				ensure
					@ole.close if @ole
				end
			end
			def set_event_handler(key, handler)
				if(handler.is_a? Symbol)
					handler = self.method(handler)
				end
				@proc_table.store(key, handler)
			end
			def set_event_handlers(hash)
				@proc_table = {}
				hash.each { |key, value|
					set_event_handler(key, value)	
				}
			end
			private
			VERSION_EXCEL95	=  0x500;
			VERSION_EXCEL97	= 0x600;
			VERSION_BIFF2		= 0x00;
			VERSION_BIFF3		= 0x02;
			VERSION_BIFF4		= 0x04;
			VERSION_BIFF5		= 0x08;
			VERSION_BIFF8		= 0x18;   #Added (Not in BOOK)
			def array(op, len, work) # DK:P297
				warn "array is not implemented"
			end
			def blank(op, len, work) # DK:P303
				row, col, fmt = work.unpack('v3')
				params = {
					:kind				=>	:blank,
					:value			=>	'',
					:format_no	=>	fmt,
					:numeric		=>	false,
				}
				cell_factory(row, col, params)
			end
			def bof(op, len, work) # Developers' Kit : P303
				version, dtype = work.unpack('v2')
				
				#Workbook Global
				if(dtype == 0x5)
					#puts "dtype: #{dtype}(0x5)"
					@workbook.version = version
					@workbook.biffversion = if(version == VERSION_EXCEL95) 
						VERSION_BIFF5 
					else
						VERSION_BIFF8
					end
					@current_sheet = nil
					@curr_sheet_idx = nil
					@prev_sheet_idx = -1
				
				#Worksheet or Dialogsheet
				elsif(dtype != 0x20)
					#puts "dtype: #{dtype}(!0x20)"
					unless(@prev_sheet_idx.nil?)
						#puts "we have a prev_sheet_index - make a new sheet"
						@curr_sheet_idx = @prev_sheet_idx += 1
						@current_sheet = @workbook.worksheet(@curr_sheet_idx)	
						if(work.length > 4)
							@current_sheet.sheet_version, 
							@current_sheet.sheet_type, = work.unpack('v2') 
						end
					else
						#puts "no current sheet_index so far..."
						@workbook.biffversion = (op/0x100).to_i
						if([VERSION_BIFF2, 
								VERSION_BIFF3, 
								VERSION_BIFF4,
							].include?(@workbook.biffversion))
							#puts "found biffversion #{sprintf('%04x', @workbook.biffversion)}"
							@workbook.version = @workbook.biffversion
							@workbook.worksheet(@workbook.sheet_count)
							@curr_sheet_idx = 0
							@current_sheet = @workbook.worksheet(@curr_sheet_idx)
						end
					end
				else
					@prev_sheet_idx = @curr_sheet_idx || -1
					@curr_sheet_idx = nil
					@current_sheet = nil
				end
			end
			def bool_err(op, len, work) # DK:P306
				row, col, fmt = work.unpack('v3')
				val, flg = work[6,2].unpack('cc')
				txt = decode_bool_err(val, flg.nonzero?)
				param = {
					:kind				=>	:bool_error,
					:value			=>	txt,
					:format_no	=>	fmt,
					:numeric		=>	false,
				}
				cell_factory(row, col, param)
			end
			def cell_factory(row, col, params)
				return if @current_sheet.nil?
				fmt = params[:format_no]
				format = params[:format] = @workbook.format(fmt)
				params[:book] = @workbook
				cell = Worksheet::Cell.new(params)
				#p format
				#cell.type = @workbook.format.cell_type(cell) unless format.nil?
				@current_sheet.add_cell(row, col, cell)
			end
			def continue(op, len, work) #DK:P311 
				# only if previous prc was Shared String Table (:sst) or :continue
				str_wk(work, true) if(@prev_prc == SST)
			end
			def conv_biff8(work, conv_flag=false)
				len, flg = work.unpack('vc')
				high = ibool(flg & 0x01)
				ext = ibool(flg & 0x04)
				rich = ibool(flg & 0x08)
				ecnt, rcnt, pos, str = 0, 0
				#2. Rich and Ext
				if(rich && ext)
					pos = 9
					rcnt, ecnt = work[3,6].unpack('vV')
				elsif(rich) #Only Rich
					pos = 5
					rcnt, = work[3,2].unpack('v')
				elsif(ext) #Only Ext
					pos = 7
					ecnt, = work[3,4].unpack('V')
				else #Nothing Special
					pos = 3
				end
				#3.Get String
				if(high) #Compressed
					len *= 2
					str = work[pos,len]
					swap_for_unicode(str)
					(str = ucs2_str(str)) unless conv_flag
				else #Not Compressed
					str = work[pos,len]
				end
				#puts [high, pos, len, rcnt, ecnt].inspect
				[str, high, pos, len, rcnt, ecnt]
			end
			def conv_biff8_data(work, conv_flag=false)
				str, high, pos, len, rcnt, ecnt = conv_biff8(work, conv_flag)
				#4. return
				spos = pos + len + rcnt*4
				epos = spos + ecnt
				#4.1 Get Rich and Ext
				#puts "work: #{work.length} < epos: #{epos} ?"
				if(work.length < epos)
					[
						[nil, high, nil, nil],
						epos,
						pos,
						len,
					]
				else
					[
						[str, high, work[spos..-1], work[spos, ecnt]],
						epos,
						pos,
						len,
					]
				end
			end
			def conv_biff8_string(work, conv_flag=false)
				conv_biff8(work, conv_flag).first
			end
			def conv_dval(val)
				val = val.unpack('c8').reverse.collect { |bit|
					bit.to_i	
				}.pack('c8') if @bigendian
				val.unpack('d').first
			end
			def decode_bool_err(val, flag=false) # DK:P306
				if(flag) # ERROR
					case val
					when 0x00
						'#NULL!'
					when 0x07
						'#DIV/0!'
					when 0x0F
						'#VALUE!'
					when 0x17
						'#REF!'
					when 0x1D
						'#NAME?'
					when 0x24
						'#NUM!'
					when 0x2A
						'#N/A!'
					else
						'#ERR'
					end
				else
					(val.nonzero?) ? 'TRUE' : 'FALSE'
				end
			end
			def default_row_height(op, len, work) # DK: P318
				return if(@current_sheet.nil?)

				#1. RowHeight
				dum, hght = work.unpack('v2')
				@current_sheet.default_row_height = hght/20.0
			end
			def flg_1904(op, len, work) # DK:P296
				@workbook.flg_1904 = work.unpack('v').first.nonzero?
			end
			def footer(op, len, work) #DK:P335
				return unless(@current_sheet)
				@current_sheet.footer = simple_string(work)
			end
			def format(op, len, work) # DK:P336
				fmt = if([
						VERSION_BIFF2, 
						VERSION_BIFF3, 
						VERSION_BIFF4, 
						VERSION_BIFF5,
					].include?(@workbook.biffversion))
					work[3, work[2,1].unpack('c').first]
				else
					conv_biff8_string(work[2..-1])
				end
				idx = work[0,2].unpack('v').first
				@workbook.add_text_format(idx, fmt)
			end
			def formula(op, len, work) # DK:P336
				row, col, fmt = work.unpack('v3')
				flag = work[12,2].unpack('v')
				if(flag == 0xffff)
					kind = work[6,1].unpack('c')
					val = work[8,1].unpack('c')
					if(1..2.include?(kind))
						txt = decode_bool_err(val, kind == 2)
						params = {
							:kind				=>	:formula_bool,
							:value			=>	txt,
							:format_no	=>	fmt,
							:numeric		=>	false,
							:code				=>	nil, 
						}
						cell_factory(row, col, params)
					else
						@prev_pos = [row, col, fmt]
					end
				else
					dval = conv_dval(work[6,8])
					params = {
						:kind				=>	:formula_number,
						:value			=>	dval,
						:format_no	=>	fmt,
						:numeric		=>	true,
						:code				=>	nil, 
					}
				end
			end
			def header(op, len, work) # DK:P340
				return unless(@current_sheet)
				@current_sheet.header = simple_string(work)
			end
			def ibool(num)
				(num != 0)
			end
			def integer(op, len, work) # Not in DK
				row, col, fmt, dum, txt = work.unpack('v3cv')
				params = {
					:kind				=>	:integer,
					:value			=>	txt,
					:format_no	=>	fmt,
					:numeric		=>	false,
				}
				cell_factory(row, col, params)
			end
			def label(op, len, work) # DK:P344
				row, col, fmt = work.unpack('v3')
				#BIFF8
				label, code = nil
				if(@workbook.biffversion && @workbook.biffversion >= VERSION_BIFF8)
					buff, tln, pos, lens = conv_biff8_data(work[6..-1], true)
					label = buff.at(0)
					code = buff.at(1) ? :ucs2 : nil
				#Before BIFF8
				else
					label = work[8..-1]
					code = :_native_
				end
				params = {
					:kind				=>	:label,
					:value			=>	label,
					:format_no	=>	fmt,
					:numeric		=>	false,
					:code				=>	code, 
				}
				cell_factory(row, col, params)
			end
			def label_sst(op, len, work) # DK: P345
				row, col, fmt, idx = work.unpack('v3V')
				reference = @workbook.pkg_str(idx) or return 
				code = (reference.unicode) ? :ucs2 : nil
				params = {
					:kind				=>	:packed_idx,
					:value			=>	reference.text,
					:format_no	=>	fmt,
					:numeric		=>	false,
					:code				=>	code, 
					:rich				=>	reference.rich
				}
				cell_factory(row, col, params)
			end
			def mul_rk(op, len, work) # DK:P349
				return nil unless (@workbook.sheet_count > 0);

				row, scol = work.unpack('v2')
				ecol, = work[-2,2].unpack('v')
				pos = 4

				scol.upto(ecol) { |col|
					#puts "unpacking: #{work[pos,6].inspect}"
					fmt, val = unpack_rk_rec(work[pos,6])
					params = {
						:kind				=>	:mul_rk,
						:value			=>	val,
						:format_no	=>	fmt,
						:numeric		=>	true,
					}
					cell_factory(row, col, params)
					pos += 6
				}
			end
			def mul_blank(op, len, work) # DK:P349
				row, scol = work.unpack('v2')
				ecol, = work[-2,2].unpack('v')
				pos = 4

				scol.upto(ecol) { |col|
					fmt, = work[pos,2].unpack('v')
					params = {
						:kind				=>	:mul_blank,
						:value			=>	'',
						:format_no	=>	fmt,
						:numeric		=>	false,
					}
					cell_factory(row, col, params)
					pos += 2
				}
			end
=begin
			def name(op, len, work) # DK: P350
				gr_bit, key, ch, cce, xals, tab, cust, dsc, hep, status = work.unpack('vc2v3c4')
				#Builtin Name + Length == 1
				if((gr_bit & 0x20).nonzero? && (ch == 1))
					#BIFF8
					if(@workbook.biffversion >= VERSION_BIFF8)
						name = work[14,2].unpack('n').first
						sheet = work[8,2].unpack('v').first - 1
						sheet_w, area = parse_name_area(work[16..-1])
						if(name == 6)								#PrintArea
							@workbook.print_area[sheet] = area
						elsif(name == 7)						#Title
							title_r = []
							title_c = []
							area.each { |array|
								if(array.at(3) == 0xFF) #Row Title	
									title_r.push([array.at(0), array.at(2)])
								else										#Col Title
									title_c.push([array.at(1), array.at(3)])
								end
							}
							@workbook.print_title[sheet] = {:row=>title_r, :column=>title_c}
						end
					else
						name = work[14,1].unpack('c')
						sheet, area = parse_name_area95(work[15..-1])
						if(name == 6)								#PrintArea
							@workbook.print_area[sheet] = area
						elsif(name == 7)						#Title
							title_r = []
							title_c = []
							area.each { |array|
								if(array.at(3) == 0xFF) #Row Title	
									title_r.push([array.at(0), array.at(2)])
								else										#Col Title
									title_c.push([array.at(1), array.at(3)])
								end
							}
							@workbook.print_title[sheet] = {:row=>title_r, :column=>title_c}
						end
					end
				end
			end
=end
			def number(op, len, work) # DK: P354
				row, col, fmt = work.unpack('v3')
				dval = conv_dval(work[6,8])
				params = {
					:kind				=>	:number,
					:value			=>	dval,
					:format_no	=>	fmt,
					:numeric		=>	true,
				}
				cell_factory(row, col, params)
			end
			def rk(op, len, work) # DK:P401
				row, col = work.unpack('v2')

				fmt, txt = unpack_rk_rec(work[4,6])
				params = {
					:kind				=>	:rk,
					:value			=>	txt,
					:format_no	=>	fmt,
					:numeric		=>	true,
					:code				=>	nil, 
				}
				cell_factory(row, col, params)
			end
			def row(op, len, work) # DK:P403
				return if(@current_sheet.nil?)

				#0. Get Worksheet info (MaxRow, MaxCol, MinRow, MinCol)
				row, scol, ecol, hght, nil1, nil2, gr, xf = work.unpack('v8')
				ecol -= 1

				#1. RowHeight
				if(ibool(gr & 0x20)) # Height == 0
					@current_sheet.set_row_height(row, 0)
				else
					@current_sheet.set_row_height(row, hght/20.0)
				end
				@current_sheet.set_dimensions(row, scol, ecol)
			end
			def rstring(op, len, work) # DK:P405
				row, col, fmt, tln = work.unpack('v4')
				params = {
					:kind				=>	:rstring,
					:value			=>	work[8,tln],
					:format_no	=>	fmt,
					:numeric		=>	false,
					:code				=>	:_native_, 
				}
				#Has STRN
				if(work.length > (8+tln))
					params.store(:rich, work[8+tln..-1])
				end
				cell_factory(row, col, params)
			end
			def setup(op, len, work) # DK: P409
				return unless(ws = @current_sheet)
				ws.paper, ws.scale, ws.page_start, ws.fit_width, ws.fit_height, \
				gr_bit, ws.resolution, ws.v_resolution = work.unpack('v8')

				ws.header_margin = conv_dval(work[16,8]) * 127 / 50 
				ws.footer_margin = conv_dval(work[24,8]) * 127 / 50 
				ws.copies, = work[32,2].unpack('v') # $oWkS->{Copis}
				ws.left_to_right = ibool(gr_bit & 0x01)
				ws.landscape		 = ibool(gr_bit & 0x02)
				ws.no_pls				 = ibool(gr_bit & 0x04)
				ws.no_color			 = ibool(gr_bit & 0x08)
				ws.draft				 = ibool(gr_bit & 0x10)
				ws.notes				 = ibool(gr_bit & 0x20)
				ws.no_orient		 = ibool(gr_bit & 0x40)
				ws.use_page			 = ibool(gr_bit & 0x80)
			end
			def simple_string(work)
				return "" if(work.empty?)
				#BIFF8
				if(@workbook.biffversion >= VERSION_BIFF8)
					str = conv_biff8_string(work)
					(str == "\x00") ? nil : str
				#Before BIFF8
				else
					len, = work.unpack('c')
					str = work[1,len]
					(str == "\x00\x00\x00") ? nil : str
				end
			end
			def sst(op, len, work) # DK:P413
				str_wk(work[8..-1])
			end
			def string(op, len, work) # DK:P414
				#Position (not enough for ARRAY)
				return if @prev_pos.nil?
				row, col, fmt = @prev_pos
				@prev_pos = nil

				txt, code = nil
				if(@workbook.biffversion == VERSION_BIFF8)
					buff, = conv_biff8_data(work, true)
					txt = buff.at(0)
					code = (buff.at(1)) ? :ucs2 : nil
				elsif(@workbook.biffversion == VERSION_BIFF5)
					code = :_native_
					tln, = work.unpack('v')
					txt = work[2,tln]
				else
					code = :_native_
					tln, = work.unpack('c')
					txt = work[1,tln]
				end
				params = {
					:kind				=>	:string,
					:value			=>	txt,
					:format_no	=>	fmt,
					:numeric		=>	false,
					:code				=>	code, 
				}
				cell_factory(row, col, params)
			end
			def str_wk(work, cnt=nil) # DK:P280
				#1. Continue
				#1.1 Before No Data No
				if(cnt.nil? || @buff == '')
					#puts "cnt was nil or buff was empty"
					@buff << work
				#1.1 No PrevCond
				elsif(@prev_cond.nil?)
					#puts "no prev_cond, adding work to buffer"
					@buff << work[1..-1]
				else
					#puts "else..."
					cnt1st = work[0] # 1st byte of Continue may be a GR byte
					stp, lens = @prev_info
					lenb = @buff.length

					#puts "cnt1st, @prev_cond"
					#p cnt1st, @prev_cond

					#1.1 Not in String
					if(lenb >= (stp + lens))
						#puts "lenb (#{lenb}) >= stp + lens (#{stp+lens})"
						@buff << work
					#1.2 Same code (Unicode or ASCII)
					elsif(((@prev_cond ? 1 : 0) & 0x01) == (cnt1st & 0x01))
						#puts "same code"
						@buff << work[1..-1]
					#1.3 Diff code (Unicode or ASCII)
					else
						#puts "codes differ"
						diff = stp + lens - lenb
						if(ibool(cnt1st & 0x01))
							#puts "new code is unicode"
							dum, gr = @buff.unpack('vc')
							@buff[2,1] = [gr | 0x01].pack('c')
							(lenb-stp).downto(1) { |idx|
								@buff[stp+idx,0] = "\x00"
							}
						else
							#puts "old code is unicode"
							(diff/2).downto(1) { |idx|
								work[idx+1,0] = "\x00"
							}
						end
						@buff << work[1..-1]
					end
				end
				@prev_cond = nil
				@prev_info = nil

				while(@buff.length >= 4)
					buff, len, stpos, lens = conv_biff8_data(@buff, true)
					#puts buff.inspect
					unless(buff[0].nil?)
						pkg_str = Worksheet::PkgString.new(*buff)
						@workbook.add_pkg_str(pkg_str)
						#puts pkg_str
						@buff = @buff[len..-1]
					else
						#puts "code convert, breaking with @prev_cond: #{buff[1]} and @prev_info: [#{stpos}, #{lens}]"
						@prev_cond = buff[1]
						@prev_info = [stpos, lens]
						break
					end
				end
			end
			def swap_for_unicode(obj)
				0.step(obj.length-2, 2) { |idx|
					it = obj[idx,1]
					obj[idx,1] = obj[idx+1,1]
					obj[idx+1,1] = it
				}
			end
			def ucs2_str(str)
				str.unpack('n*').pack('C*')
			end
			def unpack_rk_rec(arg) # DK:P401
				ef, = arg[0,2].unpack('v')
				lwk, = arg[2,4]
				swk = lwk.unpack('c4').reverse.pack('c4')
				ptn = (swk[3,1].unpack('c').first & 0x03)
				null = "\0\0\0\0"
				res = nil
				if(ptn == 0)
					#puts "ptn==0"
					res, = ((@bigendian) ? swk + null : null + lwk).unpack('d')
				elsif(ptn == 1)
					#puts "ptn==1"
					swk[3] &= [(swk[3,1].unpack('c').first & 0xFC)].pack('c')[0]
					lwk[0] &= [(lwk[0,1].unpack('c').first & 0xFC)].pack('c')[0]
					res = ((@bigendian) ? swk + null : null + lwk).unpack('d').first.to_f / 100.0
				elsif(ptn == 2)
					#puts "ptn==2"
					bin, = swk.unpack('B32')
					wklb = [((bin[0,1]*2) + bin[0,30])].pack('B32')
					wkl = (@bigendian) ? wklb : wklb.unpack('c4').reverse.pack('c4')
					res, = wkl.unpack('i')
				else
					#puts "ptn==#{ptn}"
					ub, = swk.unpack('B32')
					wklb = [((ub[0,1]*2) + ub[0,30])].pack('B32')
					wkl = (@bigendian) ? wklb : wklb.unpack('c4').reverse.pack('c4')
					res = wkl.unpack('i').first / 100.00
				end
				#p lwk, swk, swk[3,1], res if([5,12].include? res)
				[ef, res]
			end
			def ws_bool(op, len, work) # DK: P452
				return if(@current_sheet.nil?)
				fit = ibool(work.unpack('v').first & 0x100)
				@current_sheet.page_fit = fit
			end
			def xf(op, len, work) # DK:P453
				fnt, idx, lock, hidden, style, i123, alh, wrap, alv, justl = nil
				rotate, ind, shrink, merge, readdir, bdr_d, bdr_sl, bdr_sr = nil
				bdr_st, bdr_sb, bdr_sd, bdr_cl, bdr_cr, bdr_ct, bdr_cb = nil
				bdr_cd, fill_p, fill_cf, fill_cb = nil

				if(@workbook.biffversion == VERSION_BIFF8)
					fnt, idx, gen1, align, gen2, 
					bdr1, bdr2, bdr3, ptn = work.unpack('v7Vv')
					lock		= ibool(gen1 & 0x01)
					hidden	= ibool(gen1 & 0x02)
					style		= ibool(gen1 & 0x04)
					i123		= ibool(gen1 & 0x08)

					alh			= (align & 0x07)
					wrap		= ibool(align & 0x08)
					alv			= (align & 0x70) / 0x10
					justl		= ibool(align & 0x80)

					rotate	= ((align & 0xFF00) / 0x100) & 0x00FF
					rotate	= 90 if(rotate == 255)
					rotate	= (90 - rotate) if(rotate > 90)

					ind			= (gen2 & 0x0F)
					shrink	= ibool(gen2 & 0x10)
					merge		= ibool(gen2 & 0x20)
					readdir	= ((gen2 & 0xC0) / 0x40) & 0x03

					bdr_sl	= bdr1 & 0x0F
					bdr_sr	= ((bdr1 & 0xF0)	 / 0x10)	 & 0x0F
					bdr_st	= ((bdr1 & 0xF00)	 / 0x100)	 & 0x0F
					bdr_sb	= ((bdr1 & 0xF000) / 0x1000) & 0x0F

					bdr_cl	= ((bdr2 & 0x7F))						 & 0x7F
					bdr_cr	= ((bdr2 & 0x3F80) / 0x80)	 & 0x7F
					bdr_d		= ((bdr2 & 0xC000) / 0x4000) & 0x7F

					bdr_ct	= ((bdr3 & 0x7F)) & 0x7F
					bdr_cb	= ((bdr3 & 0x3F80) / 0x80) & 0x7F
					bdr_cd	= ((bdr2 & 0x1FC000) / 0x4000) & 0x7F
					bdr_sd	= ((bdr2 & 0x1E00000) / 0x200000) & 0x7F
					fill_p	= ((bdr2 & 0xFC000000) / 0x4000000) & 0x3F

					fill_cf = ptn & 0x7F
					fill_cb = ((ptn & 0x3F80) / 0x80) & 0x7F
				else
					fnt, idx, gen1, align, ptn1, ptn2, bdr1, bdr2 = work.unpack('v8')

					lock		= ibool(gen1 & 0x01)
					hidden	= ibool(gen1 & 0x02)
					style		= ibool(gen1 & 0x04)
					i123		= ibool(gen1 & 0x08)
	
					alh			= (align & 0x07)
					wrap		= ibool(align & 0x08)
					alv			= (align & 0x70) / 0x10
					justl		= ibool(align & 0x80)

					rotate	= ((align & 0x300) / 0x100) & 0x03

					fill_cf = ptn1 & 0x7F
					fill_cb = ((ptn1 & 0x1F80) / 0x80)	& 0x7F

					fill_p	= ptn2 & 0x3F
					bdr_sb	= ((ptn2 & 0x1C0)	 / 0x40)	& 0x07
					bdr_cb	= ((ptn2 & 0xFE00) / 0x200)	& 0x7F

					bdr_st	= bdr1 & 0x07
					bdr_sl	= ((bdr1 & 0x38)	 / 0x8)		& 0x07
					bdr_sr	= ((bdr1 & 0x1C0)	 / 0x40)	& 0x07
					bdr_ct	= ((bdr1 & 0xFE00) / 0x200)	& 0x7F

					bdr_cl	= (bdr2 & 0x7F)							& 0x7F
					bdr_cr	= ((bdr2 & 0x3F80) / 0x80)	& 0x7F
				end
				
				params = {
					:font_no			=>	fnt,
					#:font					=>	workbook.fonts[fnt],
					:fmt_idx			=>	idx,
					:lock					=>	lock,
					:hidden				=>	hidden,
					:style				=>	style,
					:key_123			=>	i123,
					:align_h			=>	alh,
					:wrap					=>	wrap,
					:align_v			=>	alv,
					:just_last		=>	justl,
					:rotate				=>	rotate,
					:indent				=>	ind,
					:shrink				=>	shrink,
					:merge				=>	merge,
					:read_dir			=>	readdir,
					:border_style	=>	[bdr_sl, bdr_sr, bdr_st, bdr_sb],
					:border_color	=>	[bdr_cl, bdr_cr, bdr_ct, bdr_cb],
					:border_diag	=>	[bdr_d, bdr_sd, bdr_cd],
					:fill					=>	[fill_p, fill_cf, fill_cb],
				}
				#p "**"*33
				#p work
				#p idx
				@workbook.add_cell_format(Format.new(params))
			end
		end
	end
end
