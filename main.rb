require_relative 'pdf_reading'
# require_relative 'tempfile'


# PDFTKDUMP = '/usr/bin/pdftk'




# `pdftk dp_lot.pdf cat #{page_args} output #{tmp_file.path}`
# `pdftotext -layout #{tmp_file.path}`


linkageparser = LinkageParser.new('input/test_tail_tk.txt')
linkageparser.run

puts "parcels: #{linkageparser.parcels}"

puts "linkages: #{linkageparser.linkages}"

puts "polygons: #{linkageparser.polygons}"
puts "text_notations: #{linkageparser.text_notations}"

puts "parcels.size: #{linkageparser.parcels.size}"
puts "linkages.size: #{linkageparser.linkages.size}"