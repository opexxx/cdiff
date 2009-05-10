#!/usr/bin/ruby

# cdiff.rb
#  Simple colorized binary diff.  I wrote this to help me find corruption in the shellcode
#  of something I was working on.  After writing this I found vbindiff (http://www.cjmweb.net/vbindiff/)
#  which is much better but I figure someone may find this useful.
# Requirements:
# 	Ruby gems and the term-ansicolor gem

require 'rubygems'
require 'term/ansicolor'

class String
	include Term::ANSIColor
end

def dump_file(file, changed, filename)
	ctr = 0
	puts
	puts "#{filename}: #{file.size} bytes"
	puts "---------------------------------------"
	print "00000000   "

   file.each_byte do |c|
		if (ctr % 16 == 0) && (ctr != 0)
			base = ctr - 16
			
			print "   "		
			0.upto(15) do |i|
				ch = file[base + i]
				ch = ((ch > 0x20) && (ch < 0x73)  ? ch : 0x2e)		

				print (changed[base + i] ? ch.chr.red : ch.chr.green)
			end

			print "\n#{'%08x   ' % ctr}"
		end	

		print (changed[ctr] ? "#{('%02x' % c).red} " : "#{('%02x' % c).green} ")
		ctr += 1
   end

   base = (ctr - (file.size % 16))

   print ("   " * (16 - (file.size % 16))) + "   "
	0.upto(file.size - base - 1) do |i|
		ch = file[base + i]
		ch = ((ch > 0x20) && (ch < 0x73)  ? ch : 0x2e)

		print (changed[base + i] ? ch.chr.red : ch.chr.green)
	end

	puts "\n---------------------------------------"
end

begin

	if ARGV[0].nil? || ARGV[1].nil?
		puts "Usage: ruby cdiff.rb <file1> <file2>"
		exit 0
	end	

	f1 = IO.read(ARGV[0])
	f2 = IO.read(ARGV[1])

	ctr = 0
	changed = {}
	f1.each_byte do |c|
		if f2[ctr] != c
			changed[ctr] = true	
		end
		ctr += 1
	end

	dump_file(f1, changed, ARGV[0])
	dump_file(f2, changed, ARGV[1])

rescue Exception => e
	puts e.to_s
end
