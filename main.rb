require_relative 'pdf_reading'



# PDFTKDUMP = '/usr/bin/pdftk'




# `pdftk dp_lot.pdf cat #{page_args} output #{tmp_file.path}`
# `pdftotext -layout #{tmp_file.path}`
if $0 == __FILE__

  #read the file name from the stdin and check the argument: file name has to be exist
  if ARGV.length < 1
    puts "Usage: #$0 <Input File Name>"
    exit(1)
  end

  file_name = ARGV[0]

  #check the existance of the file
  unless File.exist?(file_name)
    puts "#{file_name} is not exist."
    exit(1)
  end

  puts "Welcome to Linkage Parser"


  linkageparser = LinkageParser.new(file_name)
  linkageparser.run

  puts "parcels: #{linkageparser.parcels}"

  puts "linkages: #{linkageparser.linkages}"

  puts "polygons: #{linkageparser.polygons}"
  puts "text_notations: #{linkageparser.text_notations}"

  puts "parcels.size: #{linkageparser.parcels.size}"
  puts "linkages.size: #{linkageparser.linkages.size}"

end


