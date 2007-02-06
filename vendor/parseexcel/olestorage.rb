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
# OLEReader -- Spreadsheet::ParseExcel -- 05.06.2003 -- hwyss@ywesee.com 

require 'date'
require 'stringio'

module OLE
	class UnknownFormatError < RuntimeError; end
	class DateTime
		attr_reader :year, :month, :day, :hour, :min, :sec, :msec
		def initialize(year, month=1, day=1, hour=0, min=0, sec=0, msec=0)
			@year = year
			@month = month
			@day = day
			@hour = hour
			@min = min
			@sec = sec
			@msec = msec
		end
		def date
			begin
				Date.new(@year, @month, @day)
			rescue ArgumentError
			end
		end
		class << self
			def month_days(month, year)
				case month % 12
				when 0,1,3,5,7,8,10
					31
				when 4,6,9,11
					30
				else
					Date.leap?(year) ? 29 : 28
				end
			end
			def parse(datetime)
				#1.Divide Day and Time
				big_dt = datetime.split(//).reverse.inject(0) { |inj, char|
					inj *= 0x100
					inj += char.to_i
				}
				msec = big_dt % 10000000
				big_dt /= 10000000
				day = (big_dt / (24*60*60)) + 1
				time = big_dt % (24*60*60)
				#2. Year->Day(1601/1/2?)
				year = 1601
				attr_reader :year, :month, :day, :hour, :min, :sec, :msec
				ydays = year_days(year)
				while(day > ydays)
					day -= ydays
					year += 1
					ydays = year_days(year)
				end
				month = 1
				1.upto(11) { |month|
					mdays = month_days(month, year)
					break if(day <= mdays)
					day -= mdays
				}
				#3. Hour->iSec
				hour = time / 3600
				min = (time % 3600) / 60
				sec = time % 60
				new(year, month, day, hour, min, sec, msec)
			end
			def year_days(year)
				Date.leap?(year) ? 366 : 365
			end
		end
	end
	class Storage 
		PpsType_Root  = 5
		PpsType_Dir   = 1
		PpsType_File  = 2
		DataSizeSmall = 0x1000
		LongIntSize   = 4
		PpsSize       = 0x80
		attr_reader :header
		def initialize(filename)
      case filename
      when StringIO, File
        @fh = filename
      else 
        @fh = File.open(filename, "r")
      end
			@fh.binmode
			@header = get_header
		end
    def close
      @fh.close
    end
		module PPS
			class Node
				attr_reader :no, :type, :prev_pps, :next_pps, :data
				attr_reader :dir_pps, :time_1st, :time_2nd, :start_block, :size
				attr_reader :name
				def initialize(no, datastr)
					@no = no
					#def init(datastr)
					nm_size, @type, @prev_pps, 
					@next_pps, @dir_pps = datastr[0x40,16].unpack('vvVVV')
					@time_1st = DateTime.parse(datastr[0x64, 8])
					@time_2nd = DateTime.parse(datastr[0x6C, 8])
					@start_block, @size = datastr[0x74,8].unpack('VV')
					nm_size -= 2 if(nm_size > 2)
					@name = datastr[0,nm_size]
					#end
				end
				def get_data(header)
				end
				private
			end
			class Root < Node
				def get_data(header)
					@data = header.get_big_data(@start_block, @size)
				end
			end
			class Dir  < Node
			end
			class File < Node
				def get_data(header)
					@data = if(@size < DataSizeSmall)
						header.get_small_data(@start_block, @size)
					else 
						header.get_big_data(@start_block, @size)
					end
				end
			end
		end
		class << self
			def is_normal_block?(block)
				block < 0xFFFFFFFC
			end
			def pps_factory(pos, datastr)
				nm_size, type = datastr[0x40,4].unpack('vC')
				nm_size -= 2 if(nm_size > 2)
				nm = datastr[0,nm_size]
				klass = {
					PpsType_Root  => PPS::Root,
					PpsType_Dir   => PPS::Dir,
					PpsType_File  => PPS::File,
				}[type] or raise("unknown pps_type: #{type} / #{nm}")
				klass.new(pos, datastr)
			end
		end
		class Header
			attr_reader :big_block_size, :small_block_size, :bdb_count, :root_start
			attr_reader :sbd_start, :sbd_count, :extra_bbd_start, :extra_bbd_count
			attr_reader :bbd_info
			def initialize(fh)
				@fh = fh
				@pps_table = {}
				#BIG BLOCK SIZE
				exp = get_info(0x1E, 2, 'v')
				raise UnknownFormatError.new if exp.nil?
				@big_block_size = (2 ** exp)
				#SMALL BLOCK SIZE
				exp = get_info(0x20, 2, 'v')
				raise UnknownFormatError.new if exp.nil?
				@small_block_size = (2 ** exp) 
				#BDB Count
				@bdb_count = get_info(0x2C, 4, 'V') or raise UnknownFormatError.new
				#START BLOCK
				@root_start = get_info(0x30, 4, 'V') or raise UnknownFormatError.new 
				#SMALL BD START
				@sbd_start = get_info(0x3C, 4, 'V') or raise UnknownFormatError.new
				#SMALL BD COUNT
				@sbd_count = get_info(0x40, 4, 'V') or raise UnknownFormatError.new
				#EXTRA BBD START
				@extra_bbd_start = get_info(0x44, 4, 'V') or raise UnknownFormatError.new
				#EXTRA BBD COUNT
				@extra_bbd_count = get_info(0x48, 4, 'V')  or raise UnknownFormatError.new
				#GET BBD INFO
				@bbd_info = get_bbd_info
				#GET ROOT PPS
				@root = get_nth_pps(0)
			end
			def get_bbd_info
				bdb_count = @bdb_count
				first_count = (@big_block_size - 0x4C) / LongIntSize
				bdl_count = (@big_block_size / LongIntSize) - 1
				#1. 1st BDlist
				@fh.seek(0x4C)
				get_count = [first_count, bdb_count].min
				buff = @fh.read(LongIntSize * get_count)
				bdl_list = buff.unpack("V#{get_count}")
				bdb_count -= get_count
				#2. Extra BDList
				block = @extra_bbd_start
				while((bdb_count > 0) && Storage.is_normal_block?(block))
					set_file_pos(block, 0)
					get_count = [bdb_count, bdl_count].min
					buff = @fh.read(LongIntSize * get_count)
					bdl_list += buff.unpack("V#{get_count}")
					bdb_count -= get_count
					buff = @fh.read(LongIntSize)
					block = buff.unpack('V')
				end
				#3.Get BDs
				bd_table = {}
				block_no = 0
				bd_count = @big_block_size / LongIntSize
				bdl_list.each { |bdl|
					set_file_pos(bdl, 0)
					buff = @fh.read(@big_block_size)
					array = buff.unpack("V#{bd_count}")
					bd_count.times { |idx|
						bd_table.store(block_no, array[idx]) unless(array[idx]==block_no.next)
						block_no += 1
					}
				}
				bd_table
			end
			def get_big_data(block, size)
				result = ''
				return result unless Storage.is_normal_block?(block)
				rest = size
				keys = @bbd_info.keys.sort
				while(rest > 0)
					res = keys.select { |key| key >= block }
					nkey = res.first
					idx = nkey - block
					nxt = @bbd_info[nkey]
					set_file_pos(block, 0)
					get_size = [rest, @big_block_size * idx.next].min
					result << @fh.read(get_size)
					rest -= get_size
					block = nxt
				end
				result
			end
			def get_info(pos, len, fmt)
				@fh.seek(pos)
				if(buff = @fh.read(len))
					buff.unpack(fmt).first
				end
			end
			def get_next_block_no(block)
				@bbd_info[block] || block.next
			end
			def get_next_small_block_no(block)
				base = @big_block_size / LongIntSize
				nth = block / base
				pos = block % base
				blk = get_nth_block_no(@sbd_start, nth)
				set_file_pos(blk, pos * LongIntSize)
				@fh.read(LongIntSize).unpack('V').first
			end
			def get_nth_block_no(start_block, nth)
				nxt = start_block
				nth.times { |idx| 
					nxt = get_next_block_no(nxt)
					return nil unless Storage.is_normal_block?(nxt)
				}
				nxt
			end
			def get_nth_pps(pos)
				@pps_table.fetch(pos) {
					base_count = @big_block_size / PpsSize
					pps_block = pos / base_count
					pps_pos = pos % base_count
					
					block = get_nth_block_no(@root_start, pps_block) or return 
					set_file_pos(block, PpsSize*pps_pos)
					buff = @fh.read(PpsSize) or return 
					pps = Storage.pps_factory(pos, buff)
					pps.get_data(self)
					@pps_table.store(pos, pps)
				}
			end
			def get_small_data(block, size)
				result = ''
				rest = size
				while(rest > 0)
					set_file_pos_small(block)
					get_size = [rest, @small_block_size].min
					result << @fh.read(get_size)
					rest -= @small_block_size
					block = get_next_small_block_no(block)
				end
				result
			end
			def sb_start
				@root.start_block
			end
			def sb_size
				@root.size
			end
			def set_file_pos(block, pos)
				@fh.seek((block+1) * @big_block_size + pos)
			end
			def set_file_pos_small(block)
				base = @big_block_size / @small_block_size
				nth = block / base
				pos = block % base
				blk = get_nth_block_no(sb_start, nth)
				set_file_pos(blk, pos * @small_block_size)
			end
		end
		def search_pps(names, cse=false, no=0, done=[])
			#1. Check it self
			return [] if(done.include?(no))
			done.push(no)
			pps = @header.get_nth_pps(no) or return []
			cond = if(cse) 
				Proc.new { |name|
					/^#{Regexp.escape pps.name}$/i.match(name)
				} 
			else
				Proc.new { |name| name == pps.name }
			end
			result = if(names.any? { |name| cond.call(name) })
				[pps]
			else
				[]
			end
			#2. Check Child, Previous, Next PPSs
			[ pps.dir_pps, pps.prev_pps, pps.next_pps ].each { |node|
				unless(node == 0xFFFFFFFF)
					result += search_pps(names, cse, node, done)
				end
			}
			result	
		end
		private
		def get_header
			#0. Check ID
			@fh.rewind
			unless(@fh.read(8) == "\xD0\xCF\x11\xE0\xA1\xB1\x1A\xE1")
        raise UnknownFormatError
      end
			Header.new(@fh)
		end
	end
	def asc2ucs(str)
		str.split(//).join("\000") + "\000"
	end
	module_function :asc2ucs
end

=begin
ToDo: Merge with Daniel J. Bergers OLEWriter
=end
