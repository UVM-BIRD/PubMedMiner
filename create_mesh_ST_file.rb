# Extract MeSH terms and corresponding semantic types, save in a new file
# File "MeSH_STCode.txt" contains MeSH terms and ST in codes
# File "MeSH-STWord.txt" contains MeSH terms and ST in words

require 'rubygems'

#parse MeSH terms and corresponding semantic types, store in the newly created file
input_file = File.open("d2013.bin")
array = []
count = -1
input_file.each do |line|
  if line =~ /NEWRECORD/
    count = count + 1

  elsif line =~ /MH = (.*)/
    array[count] = "\n" + line
    
  elsif line =~ /ST = (.*)/
    array[count] = array[count] + line
    
  end
  
end
input_file.close

#export extracted MeSH terms and corresponding semantic types into a new file
output_file = File.new("MeSH_STCode.txt", "w+")
output_file.puts(array)
output_file.close

#convert ST codes into ST word description
input_file = File.open("MeSH_STCode.txt")
input_file_semgroups = File.open("SemGroups.txt")
output_file = File.open("MeSH_STWord.txt", "w+")

input_file.each do |line|
  if line =~ /ST = (.*)/
    st_extracted = line.match(/ST = (.*)/)[1]
    input_file_semgroups.each do |semgroups_line|
      if semgroups_line =~ /#{Regexp.escape(st_extracted)}/
        line.gsub!(/#{Regexp.escape(st_extracted)}/, semgroups_line.split("|").last.strip)
      end
    end
  input_file_semgroups.rewind
  end
  output_file.puts(line)
end

input_file.close
input_file_semgroups.close
output_file.close

# Store hash of all MeSH term:[Semantic type array] in yaml file
require 'yaml'

mesh_h = Hash.new
input_file = File.open("MeSH_STWord.txt")
input_file.each do |line|
  if line =~ /MH = .*/
    @mesh = line.match(/MH = (.*)/)[1]
    mesh_h[@mesh] = []
  elsif line =~ /ST = .*/
    mesh_h[@mesh] << line.match(/ST = (.*)/)[1] 
  end
end
input_file.close

File.open("MeSH_ST.yml", "w") do |file|
  file.write mesh_h.to_yaml
end

File.delete("MeSH_STCode.txt")
File.delete("MeSH_STWord.txt")
