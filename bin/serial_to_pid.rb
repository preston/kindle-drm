#!/usr/bin/env ruby

current_dir = File.dirname(File.expand_path(__FILE__))
lib_path = File.join(current_dir, '..', 'lib')
$LOAD_PATH.unshift lib_path


require 'zlib'
require 'kindle-drm'


include Kindle::DRM


code = 0
puts "\n"
puts "Mobipocket PID calculator for Amazon Kindle. Refactored, ported and packaged for Ruby by Preston Lee. Original Python code by Igor Skochinsky."
if ARGV.length == 1
	serial = ARGV[0]
	length = serial.length
	type, size, pad = serialToDeviceTypeAndPidSize(serial)
	if type.nil?
	  puts "Warning: unrecognized serial number. Please recheck input."
	  code = 1
	else
		puts "\n"
		puts "Device Type:\t#{type}"
		puts "PID:\t\t" + serialToPid(serial)
	end
else
  puts "Usage: #{__FILE__} <Kindle Serial Number>/<iPhone/iPod Touch UDID>"
end
puts "\n"

exit(code)

