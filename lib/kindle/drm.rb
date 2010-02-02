require 'zlib'

module Kindle
	
	module DRM
		
		LETTERS = "ABCDEFGHIJKLMNPQRSTUVWXYZ123456789".split(//)

		# Special cyclical redundancy check (checksumming) function.
		def crc32(s)
			(~Zlib.crc32(s, -1)) & 0xFFFFFFFF
		end

		# Generates the actual Personal ID (PID) needed to tie/untie content
		# (such as .mobi/.azw files) to a specific device.		
		def checksumPid(s)
			tmp = crc32(s)
			crc = tmp ^ (tmp >> 16)
			res = s
			l = LETTERS.length
			for i in 0..1 do
				b = crc & 0xFF
				t = b.divmod(l)[0]
				pos = t ^ (b % l)
				res = "#{res}#{LETTERS[pos % l]}"
				crc >>= 8
			end
			res
		end

		# Figures out the intermediary Personal ID (PID) of a device based on its
		# serial number and expected length of the output. Apparently this
		# various by the type of device.
		def serialToIntermediaryPid(s, l)
			crc = crc32(s)  
			arr1 = Array.new(l, 0)
			for i in 0..(s.length - 1) do
				arr1[i%l] ^= s[i]
			end

			# Grab each CRC byte and OR with a portion of the 
			crc_bytes = [crc >> 24 & 0xff, crc >> 16 & 0xff, crc >> 8 & 0xff, crc & 0xff]
			for i in 0..(l - 1) do
				arr1[i] ^= crc_bytes[i&3]
			end

			pid = ""
			for i in 0..(l-1) do
				b = arr1[i] & 0xff
				pid += LETTERS[(b >> 7) + ((b >> 5 & 3) ^ (b & 0x1f))]
			end
			pid
		end
		
		
		def serialToDeviceTypeAndPidSize(serial)
			type = nil
			size = nil
			pad = nil
			
			l = serial.length
			if l == 16
				case serial[0, 4]
				when "B001"
					type = "Kindle 1"
				when "B002"
					type = "Kindle 2"
				when "B003"
					type = "Kindle 2 International"
				when "B004"
					type = "Kindle DX"
				end
				size = 7
				pad = '*'
			elsif l == 40
				type = "iPhone"
				size = 8
			end

			return nil if type.nil? || size.nil?
			return [type, size, pad]
		end

		
		def serialToPid(serial)
			pid = nil
			type, size, pad = serialToDeviceTypeAndPidSize(serial)
			if type.nil?
				# No dice.. :(
			else
				ipid = serialToIntermediaryPid(serial, size)
				ipid += pad unless pad.nil?
				pid = checksumPid(ipid)
			end
			pid
		end
		
	end
	
end
