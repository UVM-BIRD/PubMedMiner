# Author: Yucan Zhang
# CS Mater Project
# 2013

# NOTICE: Specify the default email address to make use of the NCBI E-Utilities
# repalce xxxx@xxx.xxx with a working email address at line #109


require 'rubygems'

def prompt(*args)
    print(*args)
    gets.strip
end

# Acquire numbers from user required for rule mining and visualization
# Can be used in multiple places, specified by numType
def inputNum(prompt_string, numType)
  input = prompt prompt_string
  input = input.gsub(/\s+/, "")
  # if numType is support or confidence (used in rule mining), ask user for floating point number
  if numType == "support" or numType == "confidence"
    num = input.to_f
    while input !~ /0.\d*/ or num > 1.0 or num < 0
      puts prompt_string
      input = gets.strip.gsub(/\s+/, "")
      num = input.to_f
    end
  #if numType is k or rule_num or mh_num (used in visualization), ask user for integer
  elsif numType == "grouped_matrix_k" or numType == "rule_num" or numType == "mh_num"
    num = input.to_i
    while input !~ /\d+/ or num <= 0
      puts prompt_string
      input = gets.strip.gsub(/\s+/, "")
      num = input.to_i
    end
  #if numType is maxlength (used in rule mining), it has to be an integer greater than 2
  elsif numType == "maxlength"
    num = input.to_i
    while input !~ /\d+/ or num < 2
      puts prompt_string
      input = gets.strip.gsub(/\s+/, "")
      num = input.to_i
    end
  end
  num
end

# Ask user to specify directory to save generated files
def specifyDir
  # check if input directory exists
  def directory_exists?(directory)
    File.directory?(directory)
  end
  
  puts "*** The current working directory is #{Dir.pwd}
*** By default, all generated files be stored in the \"results\" folder in this directory.
*** For a different directory, please specify the full path. 
*** (Note: a new folder will be automatically created if the directory does not exist)"+"\n\n"
  
  
  
  dir = prompt "Enter full path of directory: "
  puts "\n"
  if dir !~ /\S/
    dir = Dir.pwd+"/results"
  end
  
  # if input directory does not exist, create the folder accordingly
  if !directory_exists?(dir)
    Dir.mkdir(dir)
    Dir.mkdir(dir+"/data")
    Dir.mkdir(dir+"/mesh")
    Dir.mkdir(dir+"/semantic_types")
    Dir.mkdir(dir+"/rules")
    File.new("#{dir}/log.txt", "w+")
  else
    if !directory_exists?(dir+"/data")
      Dir.mkdir(dir+"/data")
    end
    if !directory_exists?(dir+"/mesh")
      Dir.mkdir(dir+"/mesh")
    end
    if !directory_exists?(dir+"/semantic_types")
      Dir.mkdir(dir+"/semantic_types")
    end
    if !directory_exists?(dir+"/rules")
      Dir.mkdir(dir+"/rules")
    end
    if !File.exists?("#{dir}/log.txt")
      File.new("#{dir}/log.txt", "w+")
    end
  end
  # return input directory for the use of other methods
  dir
end


# ask user for key words
# search PubMed and retrieve MEDLINE records via NCBI E-Utilities
# save records (pubmed_result.txt) in user specified directory
# parse through raw MEDLINE records and extract PMID and associated MeSH headings
# save extracted PMID_MeSH.txt in user specified directory
def search(dir)
  searchIsSuccessful = false
  require 'bio'
  
  # fill in a working email address
  Bio::NCBI.default_email = 'xxxxx@xxx.xxx'
  
  # acquire key words from user for the search
  def acquireKey
    puts "*** SEARCH
*** Please specify a PubMed search.
*** Example: \"university of vermont\"[ad] and \"diabetes mellitus\"[mh]
*** For a tutorial, see http://www.nlm.nih.gov/bsd/disted/pubmedtutorial/cover.html" + "\n\n"

    key = prompt "Enter PubMed search: "
    puts "\n"
    while key !~ /\S/
      key = prompt "Enter PubMed search: "
      puts "\n"
    end
    key
  end
  key_str = acquireKey
  
  
  # set up parameters used for search and retrieve MEDLINE records from PubMed
  pmopts = {"db" => "pubmed", "rettype" => "medline", "retmode" => "text"}
  countopt = {"rettype" => "count"}
  @RETMAX = 100000
  maxopt = {"retmax" => @RETMAX}
  ncbi = Bio::NCBI::REST.new
  
  # search PubMed first and  get the number of related articles
  pmid_count = ncbi.esearch(key_str, pmopts.merge(countopt))
  puts "==> #{pmid_count.to_s} publications have been found for this search"
  
  # proceeds only if any articles found (search is valid)
  if (pmid_count > 0)

    searchIsSuccessful = true
    
    # search PubMed again and store PMID in an array
    pmid_array = []
    retstart = 0
    while (retstart <= pmid_count )
      pmid_array << ncbi.esearch(key_str, pmopts.merge({"retstart" => retstart}).merge(maxopt))
      retstart = retstart + @RETMAX 
    end
    
    # fetch all PMID saved in the array and store in the "pubmed_result.txt" file
    input_file = File.new("#{dir}/data/pubmed_result.txt", "w+")
    input_file.puts(ncbi.efetch(pmid_array, pmopts))
    input_file.close
        
    # parse PMID and MeSH term from each publication, store in an array first
    # Format: PMID|MeSH1^MeSH2^....^
    input_file = File.open("#{dir}/data/pubmed_result.txt")
    array = [] 
    count = -1
    input_file.each do |line|
      if line =~ /PMID- (\d*)/
        count = count + 1
        line_extracted = line.match(/PMID- (\d*)/)[1]
        array[count] = line_extracted + '|'
      elsif line =~ /MH  - (.*)/
        line_extracted = line.match(/MH  - (.*)/)[1]
        array[count] = array[count] + line_extracted + '^'
      end
    end
    input_file.close

    #export extracted PMID and MeSH terms from the array into a PMID_MeSH.txt file
    # Format: PMID|MeSH1^MeSH2^....^
    output_file = File.new("#{dir}/data/PMID_MeSH.txt", "w+")
    output_file.puts(array)
    output_file.close
    
    puts "==> MEDLINE records have been retrieved into \"#{dir}/data\"
==> PMID and MeSH terms have been extracted and reformatted into \"#{dir}/data\"" + "\n\n"

  end
  
  # update the log file.
  if (!File.exists?("#{dir}/log.txt"))
    File.new("#{dir}/log.txt")
  end
  log = File.open("#{dir}/log.txt", "a")
  time = Time.utc(*Time.new.to_a)
  log.puts "#{time} |Search PubMed| Search key words: #{key_str} | #{pmid_count} results found"
  log.close
  
  # return true if found PMID's more than 0, otherwise false
  searchIsSuccessful
end

# Further extracts MeSH headings from PMID_MeSH.txt
# format as two columns of PMID-MeSH pairs (get ready for upload as transactions)
# All files generated will be stored in user-specified directory
def extractMeSH(dir)
  require 'yaml'
  mesh_h = YAML::load_file "MeSH_ST.yml"
  
  # check if PMID_MeSH.txt exists, if not, user has to search PubMed first to generate the file
  if !File.exists?("#{dir}/data/PMID_MeSH.txt")
    puts "!!!!! WARNING: in extractMeSH : PMID_MeSH file does not exist!"
    puts ">>>>> Search PubMed again or move PMID_MeSH.txt into \"#{dir}/data\""+"\n\n"
    search(dir)
  end
  input_file = File.open("#{dir}/data/PMID_MeSH.txt")
  
  # output into PMID-MeSH pairs, reserving original quote marks. Subheadings are removed
  # Format: PMID|MeSH
  # this file will be used to convert MeSH into semantic types
  output_file = File.open("#{dir}/mesh/extracted_mesh.txt", "w")
  
  input_file.each do |line|
    mesh_list = line.split("|").last
    line = line.split("|").first 
    if mesh_list =~ /\w+/
      mesh_array = mesh_list.split("^").map(&:strip) - [""]
      
      mesh_array.each do |mesh|
        if mesh =~ /.*\/.*/
          mesh = mesh.split("/").first
        end
        if mesh =~ /\*.*/ or mesh =~ /.*\*/
          mesh = mesh.gsub(/\*/, '')
        end
        if (!(mesh_h[mesh].nil?))
          if mesh =~ /.*\'.*/
           mesh = mesh.gsub("'", "\"\'\"")
          end
          output_line = line + "|[" + mesh +"]"
          output_file.puts output_line
        end
      end
    end    
  end
  output_file.close
  input_file.close
  
end

# Convert MeSH into corresponding semantic types
# store semantic types in two formats:
# 1) extracted_semantic_types.txt: 
#    PMID-SemT pairs for calculating SemT frequency excluding duplicates related to a single PMID
# 2) extracted_semantic_types_only.txt:
#    SemT only (without PMID) for calculating frequency including duplicates
def convertToSemT(dir)
  
  # make sure extracted_mesh.txt exists
  if !File.exists?("#{dir}/mesh/extracted_mesh.txt")
    extractMeSH(dir)
  end
  
  require 'yaml'
  mesh_h = YAML::load_file "MeSH_ST.yml"

  #convert MeSH terms into corresponding semantic types with PMID
  #Format: PMID|Semantic type
  input_file = File.open("#{dir}/mesh/extracted_mesh.txt")
  output_file = File.open("#{dir}/semantic_types/extracted_semantic_types.txt", "w")
  all_st = []
  input_file.each do |line|
    mesh = line.split("|").last.strip.gsub(/[\[\]]/, "")
    if mesh =~ /.*\"\'\".*/
      mesh = mesh.gsub("\"\'\"", "\'")
    end
    line = line.split("|").first.strip
    
    mesh_h[mesh].each do |st|
      all_st << st
      output_line = line + "|" + st
      output_file.puts output_line
    end
  end
  input_file.close
  output_file.close
  
  #save all semantic types without PMID in another file
  output_file = File.open("#{dir}/semantic_types/extracted_semantic_types_only.txt","w")
  output_file.puts all_st
  output_file.close
end

# Count occurrence of MeSH terms and semantic types
# Since multiple MeSH terms might point to the same semantic type, 
# the same semantic type might appear multiple times within one MEDLINE record.
# Thus, semantic type counting is implemented with and without duplicates
def statistics_all(dir, r)
    
  puts "*** STATISTICS
*** Basic statistics for all MeSH terms and semantic types will be calculated.
*** For graphs, please specify number to be displayed (top 10, top 20, etc.)" + "\n\n"

  # if any of the required files (generated by extractMeSH or convertToSemT) does not exist, 
  # do the extractMeSH() and convertToSemT() first
  if !File.exists?("#{dir}/mesh/extracted_mesh.txt") or !File.exists?("#{dir}/semantic_types/extracted_semantic_types.txt") or !File.exists?("#{dir}/semantic_types/extracted_semantic_types_only.txt")
    extractMeSH(dir)
    convertToSemT(dir)
  end
  
  if File.zero?("#{dir}/mesh/extracted_mesh.txt") or File.zero?("#{dir}/semantic_types/extracted_semantic_types.txt")
    puts "!!!!! WARNING in statistics after search : NO MeSH terms or semantic types found\n"
  else
    
    input_file = File.open("#{dir}/mesh/extracted_mesh.txt")
    output_file = File.open("#{dir}/mesh/extracted_mesh_statistics.txt", "w+")
    input_file.each do |line|
      line = line.gsub(/[\[\]]/, "")
      output_file.puts line
    end
    input_file.close
    output_file.close
    
    r.eval <<-EOF
      suppressMessages(library("arules"))
    EOF
  
    #upload PMID|MeSH into transactions
    r.eval <<-EOF
      trans_mh <- read.transactions("#{dir}/mesh/extracted_mesh_statistics.txt", format="single", sep="|",cols=c(1,2), rm.duplicates=TRUE)
    EOF
    
    #plot the absolute count and relative frequency of mesh terms, graphs are saved in pdf
    # ask for the number of MeSH terms plotted in the histogram
    mh_num = inputNum("Enter the number of MeSH terms to be displayed in graphs (integer > 0): ", "mh_num")   
    puts "\n"
    r.eval <<-EOF  
      pdf("#{dir}/mesh/mesh_term_count.pdf")
      itemFrequencyPlot(trans_mh, topN = #{mh_num}, type="absolute", names = TRUE)
      dev.off()
      pdf("#{dir}/mesh/mesh_term_frequency.pdf")
      itemFrequencyPlot(trans_mh, topN=#{mh_num}, type="relative", names=TRUE)
      dev.off()
    EOF
    
    #output absolute count and relative frequency of each mesh term into text file
    #Format: mesh_term|absolute_count|relative_frequency
    #all the temporary files (will be deleted) are created in the working directory, not user specified directory
    r.eval <<-EOF
      relative_freq = itemFrequency(trans_mh,type="relative")
      absolute_count = itemFrequency(trans_mh,type="absolute")
      write.table(absolute_count, file = "mesh_term_count_temp.txt", sep = "|", quote=FALSE,col.names=FALSE)
      write.table(relative_freq,file="mesh_term_frequency_temp.txt",sep="|",quote=FALSE,col.names=FALSE)
    EOF
    input_file1 = File.open("mesh_term_count_temp.txt")
    input_file2 = File.open("mesh_term_frequency_temp.txt")
    output_file = File.open("#{dir}/mesh/mesh_term_statistics_temp.txt", "w")
    input_file1.each do |line1,index1|
      input_file2.each do |line2,index2|
        if index1 == index2
          freq = line2.split("|").last
          output = line1.strip + "|" + freq
          output_file.puts output
          break;
        end
      end
    end
    input_file1.close
    input_file2.close
    output_file.close
    File.delete("mesh_term_count_temp.txt")
    File.delete("mesh_term_frequency_temp.txt")
    File.delete("#{dir}/mesh/extracted_mesh_statistics.txt")
    
    #load all semantic types with PMID into R for frequency count without duplicates in each record
    r.eval <<-EOF
      #upload records into transaction format
      trans_st1 <- read.transactions("#{dir}/semantic_types/extracted_semantic_types.txt", format="single",sep="|",cols=c(1,2), rm.duplicates = TRUE)
    EOF
    
    #plot the absolute count and relative frequency of semantic types without duplicate in each record
    #ask for number of semantic types to be displayed in the histogram
    #save all graphs in pdf's
    st_num = inputNum("Enter the number of semantic types to be displayed in graphs (integer > 0): ", "mh_num")   
    puts "\n"
    r.eval <<-EOF  
      pdf("#{dir}/semantic_types/semantic_type_count_without_duplicates.pdf")
      itemFrequencyPlot(trans_st1, topN = #{st_num}, type="absolute", names = TRUE)
      dev.off()
      pdf("#{dir}/semantic_types/semantic_type_frequency_without_duplicates.pdf")
      itemFrequencyPlot(trans_st1, topN = #{st_num}, type="relative", names = TRUE)
      dev.off()
    EOF
    
    #load all semantic types without PMID into R for frequency count
    #duplicated semantic types in each record are not removed 
    r.eval <<-EOF
      #upload records into transaction format
      trans_st2 <- read.transactions("#{dir}/semantic_types/extracted_semantic_types_only.txt", format="basket", sep = "/n")
    EOF
    
    #plot the absolute count and relative frequency of all semantic types with possible duplication within each record
    #the same number of semantic types will be displayed in the histogram (user input earlier before counting semantic type without duplicate)
    #all graphs are saved into pdf's
    r.eval <<-EOF  
      pdf("#{dir}/semantic_types/semantic_type_count_including_duplicates.pdf")
      itemFrequencyPlot(trans_st2, topN = #{st_num}, type="absolute", names = TRUE)
      dev.off()
      pdf("#{dir}/semantic_types/semantic_type_frequency_including_duplicates.pdf")
      itemFrequencyPlot(trans_st2, topN = #{st_num}, type="relative", names = TRUE)
      dev.off()
    EOF
    
    #output relative frequency and absolute count of each semantic type with duplicates into text file
    #implemented in two rounds, first adds absolute counts, second adds relative frequency
    r.eval <<-EOF
      relative_freq_with_dup = itemFrequency(trans_st2,type="relative")
      absolute_count_with_dup = itemFrequency(trans_st2,type="absolute")
      relative_freq_without_dup = itemFrequency(trans_st1,type="relative")
      absolute_count_without_dup = itemFrequency(trans_st1,type="absolute")
      
      write.table(absolute_count_with_dup, file = "st_count_dup_temp.txt", sep = "|", quote=FALSE,col.names=FALSE)
      absolute_count_with_dup_table <- read.transactions("st_count_dup_temp.txt", sep = "|", format = "single", cols=c(1,2), rm.duplicates = FALSE)
      write.table(relative_freq_with_dup,file="st_frequency_dup_temp.txt",sep="|",quote=FALSE,col.names=FALSE)
      relative_freq_with_dup_table <- read.transactions("st_frequency_dup_temp.txt", sep = "|", format = "single", cols=c(1,2), rm.duplicates = FALSE)
    EOF
    
    
    #adds relative frequency and absolute count of each semantic type without duplicates into text file
    r.eval <<-EOF   
      write.table(absolute_count_without_dup, file = "st_count_nodup_temp.txt", sep = "|", quote=FALSE,col.names=FALSE)
      absolute_count_without_dup_table <- read.transactions("st_count_nodup_temp.txt", sep = "|", format = "single", cols=c(1,2), rm.duplicates = TRUE)
      write.table(relative_freq_without_dup,file="st_frequency_nodup_temp.txt",sep="|",quote=FALSE,col.names=FALSE)
      relative_freq_without_dup_table <- read.transactions("st_frequency_nodup_temp.txt", sep = "|", format = "single", cols=c(1,2), rm.duplicates = TRUE)
    EOF
      
    #output all statistics of semantic types into one text file
    #Format: semantic_type|count(with dup)|relative_freq(with dup)|count(without dup)|relative_freq(without dup)
    st_count_dup_temp = File.open("st_count_dup_temp.txt", "r+")
    st_frequency_dup_temp = File.open("st_frequency_dup_temp.txt", "r+")
    st_count_nodup_temp = File.open("st_count_nodup_temp.txt", "r+")
    st_frequency_nodup_temp = File.open("st_frequency_nodup_temp.txt", "r+")
    output_file = File.open("#{dir}/semantic_types/semantic_type_statistics.txt", "w")
    output_file.puts "semantic_type|count(with dup)|relative_freq(with dup)|count(without dup)|relative_freq(without dup)"
    st_count_dup_temp.each do |line1,index1|
      st_frequency_dup_temp.each do |line2,index2|   
        if index1 == index2
          cur = line2.split("|").last.strip
          output = line1.strip + "|" + cur
          st_count_nodup_temp.each do |line3,index3|
            if index2 == index3
              cur = line3.split("|").last.strip
              output = output + "|" + cur
              st_frequency_nodup_temp.each do |line4,index4|
                if index3 == index4
                  cur = line4.split("|").last.strip
                  output = output + "|" + cur
                  break;
                end
              end
              break;
            end 
          end
          output_file.puts output
          break;
        end
      end
    end
    st_count_dup_temp.close
    st_frequency_dup_temp.close
    st_count_nodup_temp.close
    st_frequency_nodup_temp.close
    output_file.close
    
    File.delete("st_count_nodup_temp.txt")
    File.delete("st_frequency_nodup_temp.txt")
    File.delete("st_count_dup_temp.txt")
    File.delete("st_frequency_dup_temp.txt")
    
    # The following two files are generated in convertToSemT(), and only used in statistics() method. 
    # So delete them at the end of this method. 
    # Because convertToSemT() is called at the beginning of statistics(), they will be generated again every time statistics() is called
    File.delete("#{dir}/semantic_types/extracted_semantic_types.txt")
    File.delete("#{dir}/semantic_types/extracted_semantic_types_only.txt")
    
    # Add corresponding semantic type
    require 'yaml'
    mesh_h = YAML::load_file "MeSH_ST.yml"
  
    #convert MeSH terms into corresponding semantic types with PMID
    #Format: PMID|Semantic type
    input_file = File.open("#{dir}/mesh/mesh_term_statistics_temp.txt", "r+")
    output_file = File.open("#{dir}/mesh/mesh_term_statistics.txt", "w")
    output_file.puts "mesh_term|absolute_count|relative_frequency|semantic_type"
    input_file.each do |line|
      if line !~ /^\n/
        line = line.gsub(/[\[\]]/, "")
        mesh = line.split("|").first.strip
        mesh_h[mesh].each do |st|
          output_line = line.strip + "|" + st
          output_file.puts output_line
        end
      end
    end
    input_file.close
    output_file.close
    File.delete("#{dir}/mesh/mesh_term_statistics_temp.txt")
  
    puts "==> MeSH statistics and graphs saved to \"#{dir}/mesh\"
==> Semantic type statistics and graphs saved to \"#{dir}/semantic_types\"" + "\n\n"
  
  end  

end

# Filter MeSH terms according to user input semantic type(s)
def filter(dir)

  puts "*** FILTER BY SEMANTIC TYPE(S)
*** Please specify semantic type(s) to filter by or \"all\" to keep all semantic types.
*** Example: Disease or Syndrome|Mental or Behavioral Dysfunction|Neoplastic Process
*** For complete list, see http://www.nlm.nih.gov/research/umls/META3_current_semantic_types.html
*** or select based on results in \"#{dir}/semantic_types\""+"\n\n"

  require 'yaml'
  mesh_h = YAML::load_file "MeSH_ST.yml"
  
  # acquire semantic type(s) from user. "all" means to save all MeSH terms
  def acquireST
    input_st_array = []
    
    st_list = prompt "Enter semantic type(s) separated by '|': "
    puts "\n"
    while st_list !~ /\S/
      st_list = prompt "Enter semantic type(s) separated by '|': "  
      puts "\n"  
    end
    input_st_array = st_list.split("|").map(&:strip)
    input_st_array
  end
  input_st_array = acquireST
  
  # check if extracted_mesh.txt exists. If not, call extractMeSH() to generate it.
  if !File.exists?("#{dir}/mesh/extracted_mesh.txt")
    extractMeSH(dir)
  end
  
  # if "all", no need to filter, just save all MeSH terms from extracted_mesh.txt into filtered_mesh.txt
  if input_st_array[0].downcase == "all"
    output_file = File.open("#{dir}/mesh/filtered_mesh.txt", "w")
      
    input_file = File.open("#{dir}/mesh/extracted_mesh.txt")
    
    input_file.each do |line|
      output_file.puts line
    end
    input_file.close
    output_file.close
    
    # update the log file.
    if (!File.exists?("#{dir}/log.txt"))
      File.new("#{dir}/log.txt")
    end
    log = File.open("#{dir}/log.txt", "a")
    time = Time.utc(*Time.new.to_a)
    log.puts "#{time} |Filtering MeSH| Semantic types for filtering MeSH: #{input_st_array}"
    log.close
    
    puts "==> PMID and MeSH terms have been filtered in \"#{dir}/data\""
    puts "\n"
    
  # if one or more semantic type(s) are entered, filter the extracted_mesh.txt file
  else   
    input_file = File.open("#{dir}/mesh/extracted_mesh.txt")
    output_file = File.open("#{dir}/mesh/filtered_mesh.txt", "w")
    input_file.each do |line|
      mesh = line.split("|").last.strip.gsub(/[\[\]]/, "")
      if mesh =~ /.*\"\'\".*/
        mesh = mesh.gsub("\"", "")
      end
      line = line.strip
      if (!(mesh_h[mesh].nil?)) and (!((mesh_h[mesh].map(&:downcase) & input_st_array.map(&:downcase)).empty?))
        output_file.puts line
      end
    end 
    input_file.close
    output_file.close
    
       
    # Check if any MeSH terms are saved. If not, give a warning, filter again, maybe using different semantic types
    if(File.zero?("#{dir}/mesh/filtered_mesh.txt"))
      puts "!!!!! WARNING: No MeSH terms found!"
      puts ">>>>> Filter again with different semantic type(s)\n\n"
      filter(dir)
    end
    
    # update the log file.
    if (!File.exists?("#{dir}/log.txt"))
      File.new("#{dir}/log.txt")
    end
    log = File.open("#{dir}/log.txt", "a")
    time = Time.utc(*Time.new.to_a)
    log.puts "#{time} |Filtering MeSH| Filtered with: #{input_st_array}"
    log.close
    
    puts "==> PMID and MeSH terms have been filtered in \"#{dir}/data\""
    puts "\n"
  end
  
end

def convert_filtered_mesh_to_sem(dir)
  # make sure filtered_mesh.txt exists
  if !File.exists?("#{dir}/mesh/filtered_mesh.txt")
    filter(dir)
  end
  
  require 'yaml'
  mesh_h = YAML::load_file "MeSH_ST.yml"

  #convert MeSH terms into corresponding semantic types with PMID
  #Format: PMID|Semantic type
  input_file = File.open("#{dir}/mesh/filtered_mesh.txt")
  output_file = File.open("#{dir}/semantic_types/filtered_semantic_types.txt", "w")
  all_st = []
  input_file.each do |line|
    mesh = line.split("|").last.strip.gsub(/[\[\]]/, "")
    if mesh =~ /.*\"\'\".*/
      mesh = mesh.gsub("\"", "")
    end
    line = line.split("|").first.strip
    
    mesh_h[mesh].each do |st|
      all_st << st
      output_line = line + "|" + st
      output_file.puts output_line
    end
  end
  input_file.close
  output_file.close
  
  #save all semantic types without PMID in another file
  output_file = File.open("#{dir}/semantic_types/filtered_semantic_types_only.txt","w")
  output_file.puts all_st
  output_file.close

end
# Count occurrence of MeSH terms and semantic types after filtering with certain semantic type(s)
# Since multiple MeSH terms might point to the same semantic type, 
# the same semantic type might appear multiple times within one MEDLINE record.
# Thus, semantic type counting is implemented with and without duplicates
def statistics_filtered(dir, r)
    
  puts "*** STATISTICS AFTER FILTERING
*** Basic statistics for filtered MeSH terms and semantic types will be calculated.
*** For graphs, please specify number to be displayed (top 10, top 20, etc.)" + "\n\n"

  # if any of the required files (generated by extractMeSH or convertToSemT) does not exist, 
  # do the extractMeSH() and convertToSemT() first
  if !File.exists?("#{dir}/mesh/filtered_mesh.txt") 
    filter(dir)
  end
  
  if !File.exists?("#{dir}/semantic_types/filtered_semantic_types.txt") or !File.exists?("#{dir}/semantic_types/filtered_semantic_types_only.txt")
    convert_filtered_mesh_to_sem(dir)
  end
  
  if File.zero?("#{dir}/mesh/filtered_mesh.txt") or File.zero?("#{dir}/semantic_types/filtered_semantic_types.txt")
    puts "!!!!! WARNING in statistics after filtering : NO MeSH terms or semantic types found\n"
    
  else
    
    input_file = File.open("#{dir}/mesh/filtered_mesh.txt")
    output_file = File.open("#{dir}/mesh/filtered_mesh_statistics.txt", "w+")
    input_file.each do |line|
      line = line.gsub(/[\[\]]/, "")
      output_file.puts line
    end
    input_file.close
    output_file.close
    
    r.eval <<-EOF
      suppressMessages(library("arules"))
    EOF
  
    #upload PMID|MeSH into transactions
    r.eval <<-EOF
      trans_mh <- read.transactions("#{dir}/mesh/filtered_mesh_statistics.txt", format="single",sep="|",cols=c(1,2), rm.duplicates=TRUE)
    EOF
    File.delete("#{dir}/mesh/filtered_mesh_statistics.txt")
    
    #plot the absolute count and relative frequency of mesh terms, graphs are saved in pdf
    # ask for the number of MeSH terms plotted in the histogram
    mh_num = inputNum("Enter the number of MeSH terms to be displayed in graphs (integer > 0): ", "mh_num")   
    puts "\n"
    r.eval <<-EOF  
      pdf("#{dir}/mesh/filtered_mesh_term_count.pdf")
      itemFrequencyPlot(trans_mh, topN = #{mh_num}, type="absolute", names = TRUE)
      dev.off()
      pdf("#{dir}/mesh/filtered_mesh_term_frequency.pdf")
      itemFrequencyPlot(trans_mh, topN=#{mh_num}, type="relative", names=TRUE)
      dev.off()
    EOF
    
    #output absolute count and relative frequency of each mesh term into text file
    #Format: mesh_term|absolute_count|relative_frequency
    #all the temporary files (will be deleted) are created in the working directory, not user specified directory
    r.eval <<-EOF
      relative_freq = itemFrequency(trans_mh,type="relative")
      absolute_count = itemFrequency(trans_mh,type="absolute")
      write.table(absolute_count, file = "filtered_mesh_term_count_temp.txt", sep = "|", quote=FALSE,col.names=FALSE)
      write.table(relative_freq,file="filtered_mesh_term_frequency_temp.txt",sep="|",quote=FALSE,col.names=FALSE)
    EOF
    input_file1 = File.open("filtered_mesh_term_count_temp.txt")
    input_file2 = File.open("filtered_mesh_term_frequency_temp.txt")
    output_file = File.open("#{dir}/mesh/filtered_mesh_term_statistics_temp.txt", "w")
    input_file1.each do |line1,index1|
      input_file2.each do |line2,index2|
        if index1 == index2
          freq = line2.split("|").last
          output = line1.strip + "|" + freq
          output_file.puts output
          break;
        end
      end
    end
    input_file1.close
    input_file2.close
    output_file.close
    File.delete("filtered_mesh_term_count_temp.txt")
    File.delete("filtered_mesh_term_frequency_temp.txt")
    
    # Add corresponding semantic type
    require 'yaml'
    mesh_h = YAML::load_file "MeSH_ST.yml"
  
    #convert MeSH terms into corresponding semantic types with PMID
    #Format: PMID|Semantic type
    input_file = File.open("#{dir}/mesh/filtered_mesh_term_statistics_temp.txt", "r+")
    output_file = File.open("#{dir}/mesh/filtered_mesh_term_statistics.txt", "w")
    output_file.puts "filtered_mesh_term|absolute_count|relative_frequency|semantic_type"
    input_file.each do |line|
      line = line.gsub(/[\[\]]/, "")
      mesh = line.split("|").first.strip
      mesh_h[mesh].each do |st|
        output_line = line.strip + "|" + st
        output_file.puts output_line
      end
    end
    input_file.close
    output_file.close
    File.delete("#{dir}/mesh/filtered_mesh_term_statistics_temp.txt")
    
    
    convert_filtered_mesh_to_sem(dir)
    
    #load all semantic types with PMID into R for frequency count without duplicates in each record
    r.eval <<-EOF
      #upload records into transaction format
      trans_st1 <- read.transactions("#{dir}/semantic_types/filtered_semantic_types.txt", format="single",sep="|",cols=c(1,2), rm.duplicates = TRUE)
    EOF
    
    #plot the absolute count and relative frequency of semantic types without duplicate in each record
    #ask for number of semantic types to be displayed in the histogram
    #save all graphs in pdf's
    st_num = inputNum("Enter the number of semantic types to be displayed in graphs (integer > 0): ", "mh_num")   
    puts "\n"
    r.eval <<-EOF  
      pdf("#{dir}/semantic_types/filtered_semantic_type_count_without_duplicates.pdf")
      itemFrequencyPlot(trans_st1, topN = #{st_num}, type="absolute", names = TRUE)
      dev.off()
      pdf("#{dir}/semantic_types/filtered_semantic_type_frequency_without_duplicates.pdf")
      itemFrequencyPlot(trans_st1, topN = #{st_num}, type="relative", names = TRUE)
      dev.off()
    EOF
    
    #load all semantic types without PMID into R for frequency count
    #duplicated semantic types in each record are not removed 
    r.eval <<-EOF
      #upload records into transaction format
      trans_st2 <- read.transactions("#{dir}/semantic_types/filtered_semantic_types_only.txt", format="basket", sep = "/n")
    EOF
    
    #plot the absolute count and relative frequency of all semantic types with possible duplication within each record
    #the same number of semantic types will be displayed in the histogram (user input earlier before counting semantic type without duplicate)
    #all graphs are saved into pdf's
    r.eval <<-EOF  
      pdf("#{dir}/semantic_types/filtered_semantic_type_count_including_duplicates.pdf")
      itemFrequencyPlot(trans_st2, topN = #{st_num}, type="absolute", names = TRUE)
      dev.off()
      pdf("#{dir}/semantic_types/filtered_semantic_type_frequency_including_duplicates.pdf")
      itemFrequencyPlot(trans_st2, topN = #{st_num}, type="relative", names = TRUE)
      dev.off()
    EOF
    
    #output relative frequency and absolute count of each semantic type with duplicates into text file
    #implemented in two rounds, first adds absolute counts, second adds relative frequency
    r.eval <<-EOF
      relative_freq_with_dup = itemFrequency(trans_st2,type="relative")
      absolute_count_with_dup = itemFrequency(trans_st2,type="absolute")
      relative_freq_without_dup = itemFrequency(trans_st1,type="relative")
      absolute_count_without_dup = itemFrequency(trans_st1,type="absolute")
      
      write.table(absolute_count_with_dup, file = "filtered_st_count_dup_temp.txt", sep = "|", quote=FALSE,col.names=FALSE)
      absolute_count_with_dup_table <- read.transactions("filtered_st_count_dup_temp.txt", sep = "|", format = "single", cols=c(1,2), rm.duplicates = FALSE)
      write.table(relative_freq_with_dup,file="filtered_st_frequency_dup_temp.txt",sep="|",quote=FALSE,col.names=FALSE)
      relative_freq_with_dup_table <- read.transactions("filtered_st_frequency_dup_temp.txt", sep = "|", format = "single", cols=c(1,2), rm.duplicates = FALSE)
    EOF
    
    
    #adds relative frequency and absolute count of each semantic type without duplicates into text file
    r.eval <<-EOF   
      write.table(absolute_count_without_dup, file = "filtered_st_count_nodup_temp.txt", sep = "|", quote=FALSE,col.names=FALSE)
      absolute_count_without_dup_table <- read.transactions("filtered_st_count_nodup_temp.txt", sep = "|", format = "single", cols=c(1,2), rm.duplicates = TRUE)
      write.table(relative_freq_without_dup,file="filtered_st_frequency_nodup_temp.txt",sep="|",quote=FALSE,col.names=FALSE)
      relative_freq_without_dup_table <- read.transactions("filtered_st_frequency_nodup_temp.txt", sep = "|", format = "single", cols=c(1,2), rm.duplicates = TRUE)
      #st_nodup_table <- merge(absolute_count_without_dup_table, relative_freq_without_dup_table)
      #write(st_nodup_table, file="st_nodup_temp.txt", quote=FALSE, sep = "|")
    EOF
      
    #output all statistics of semantic types into one text file
    #Format: semantic_type|count(with dup)|relative_freq(with dup)|count(without dup)|relative_freq(without dup)
    st_count_dup_temp = File.open("filtered_st_count_dup_temp.txt", "r+")
    st_frequency_dup_temp = File.open("filtered_st_frequency_dup_temp.txt", "r+")
    st_count_nodup_temp = File.open("filtered_st_count_nodup_temp.txt", "r+")
    st_frequency_nodup_temp = File.open("filtered_st_frequency_nodup_temp.txt", "r+")
    output_file = File.open("#{dir}/semantic_types/filtered_semantic_type_statistics.txt", "w")
    output_file.puts "filtered_semantic_type|count(with dup)|relative_freq(with dup)|count(without dup)|relative_freq(without dup)"
    st_count_dup_temp.each do |line1,index1|
      st_frequency_dup_temp.each do |line2,index2|   
        if index1 == index2
          cur = line2.split("|").last.strip
          output = line1.strip + "|" + cur
          st_count_nodup_temp.each do |line3,index3|
            if index2 == index3
              cur = line3.split("|").last.strip
              output = output + "|" + cur
              st_frequency_nodup_temp.each do |line4,index4|
                if index3 == index4
                  cur = line4.split("|").last.strip
                  output = output + "|" + cur
                  break;
                end
              end
              break;
            end 
          end
          output_file.puts output
          break;
        end
      end
    end
    st_count_dup_temp.close
    st_frequency_dup_temp.close
    st_count_nodup_temp.close
    st_frequency_nodup_temp.close
    output_file.close
    
    File.delete("filtered_st_count_nodup_temp.txt")
    File.delete("filtered_st_frequency_nodup_temp.txt")
    File.delete("filtered_st_count_dup_temp.txt")
    File.delete("filtered_st_frequency_dup_temp.txt")
    
    # The following two files are generated in convertToSemT(), and only used in statistics() method. 
    # So delete them at the end of this method. 
    # Because convertToSemT() is called at the beginning of statistics(), they will be generated again every time statistics() is called
    File.delete("#{dir}/semantic_types/filtered_semantic_types.txt")
    File.delete("#{dir}/semantic_types/filtered_semantic_types_only.txt")
    
    puts "==> MeSH statistics and graphs saved to \"#{dir}/mesh\"
==> Semantic type statistics and graphs saved to \"#{dir}/semantic_types\"" + "\n\n"
    
  end
  
end

  
# Association rule mining based on filtered MeSH terms
def mineRules(dir, r)
  
  puts "*** RULE MINING - GENERATION
*** Please specify support and confidence values to use as cutoffs as well as 
*** the maximum length of rules." + "\n\n"

  # Proceed only if any filtered MeSH file exist, and contains any MeSH terms
  if File.exists?("#{dir}/mesh/filtered_mesh.txt") and !File.zero?("#{dir}/mesh/filtered_mesh.txt")          
    r.eval <<-EOF
      #load arules package
      suppressMessages(library("arules"))
      #load arulesViz library to visualize mined rules
      suppressMessages(library("arulesViz"))
    
      #upload records into transaction format
      trans <- read.transactions("#{dir}/mesh/filtered_mesh.txt", format="single",sep="|",cols=c(1,2))
      
      #review the uploaded transactions
      #summary(trans)
    EOF

    # user input support value
    support_value = inputNum("Enter support value (decimal between 0.0 and 1.0): ", "support")
    puts "\n"
    
    # user input confidence value
    confidence_value = inputNum("Enter confidence value (decimal between 0.0 and 1.0): ", "confidence")
    puts "\n"
    
    # user input maxlength value
    maxlength = inputNum("Enter the maximum length for rules (integer >= 2): ", "maxlength")
    puts "\n"
    
    # apply apriori algorithm to look for association rules and saved in a vector
    r.eval <<-EOF
      apriori_rules <- apriori(trans, parameter=list(supp = #{support_value}, conf = #{confidence_value}, maxlen = #{maxlength}, minlen = 2))
      quality(apriori_rules) <- cbind(quality(apriori_rules),chiSquare = interestMeasure(apriori_rules, method = "chiSquare", trans))
      quality(apriori_rules) <- cbind(quality(apriori_rules),conviction = interestMeasure(apriori_rules, method = "conviction", trans))
      quality(apriori_rules) <- cbind(quality(apriori_rules),cosine = interestMeasure(apriori_rules, method = "cosine", trans))
      quality(apriori_rules) <- cbind(quality(apriori_rules),coverage = interestMeasure(apriori_rules, method = "coverage", trans))
      quality(apriori_rules) <- cbind(quality(apriori_rules),doc = interestMeasure(apriori_rules, method = "doc", trans))
      quality(apriori_rules) <- cbind(quality(apriori_rules),hyperLift = interestMeasure(apriori_rules, method = "hyperLift", trans))
      quality(apriori_rules) <- cbind(quality(apriori_rules),hyperConfidence = interestMeasure(apriori_rules, method = "hyperConfidence", trans))
      quality(apriori_rules) <- cbind(quality(apriori_rules),fishersExactTest = interestMeasure(apriori_rules, method = "fishersExactTest", trans))
      quality(apriori_rules) <- cbind(quality(apriori_rules),gini = interestMeasure(apriori_rules, method = "gini", trans))
      quality(apriori_rules) <- cbind(quality(apriori_rules),improvement = interestMeasure(apriori_rules, method = "improvement", trans))
      quality(apriori_rules) <- cbind(quality(apriori_rules),leverage = interestMeasure(apriori_rules, method = "leverage", trans))
      quality(apriori_rules) <- cbind(quality(apriori_rules),oddsRatio = interestMeasure(apriori_rules, method = "oddsRatio", trans))
      quality(apriori_rules) <- cbind(quality(apriori_rules),phi = interestMeasure(apriori_rules, method = "phi", trans))
      quality(apriori_rules) <- cbind(quality(apriori_rules),RLD = interestMeasure(apriori_rules, method = "RLD", trans))
      
      apriori_rules <- sort(apriori_rules, decreasing = TRUE, by = "chiSquare")
      #summary(apriori_rules)
      num_rules <- length(apriori_rules)
    EOF
    
    # Proceed only if > 0 rules are found
    if(r.num_rules != 0)
      
      #output all mined rules and summary using apriori algorithm ordered by lift into temporary text file
      r.eval <<-EOF
        write(apriori_rules, file = "apriori_rules_temp.txt", sep = "|", col.names = TRUE, row.names = FALSE)
      EOF
      
      # add pubmed query link, the query is composed of LHS and RHS mesh terms
      # Rules with links are output into the final apriori_rules.txt file
      input_file = File.open("apriori_rules_temp.txt")
      output_file = File.open("#{dir}/rules/apriori_rules.txt","w")
      input_file.each_with_index do |line, index|
        if index == 0
          line["rules"] = "lhs|rhs"
          line = line.rstrip + "|PubMed query"
          output_file.puts line
        else
          query = "|http://www.ncbi.nlm.nih.gov/pubmed/?term=\""
          rule = line.split("|").first.gsub("], [", "],[")
          lhs = rule.split(" => ").first.gsub("{","").gsub("}","")
          lhs_mesh = []
          lhs_mesh << lhs.split("],[")
          lhs_mesh = lhs_mesh.flatten
          lhs_mesh.each do |mesh|
            mesh = mesh.gsub(/[\[\]]/, "")
            query = query + mesh + "\"[mh] and \""
          end
          
          rhs = rule.split(" => ").last.gsub("{","")
          rhs_mesh = []
          rhs_mesh << rhs.split("],[")
          rhs_mesh = rhs_mesh.flatten
          rhs_mesh.each do |mesh|
            mesh = mesh.gsub(/[\[\]]/, "")
            if mesh =~ /.*}/
              mesh = mesh.gsub("}", "")
              query = query + mesh + "\"[mh]"
            else
              query = query + mesh + "\"[mh] and \""
            end
          end
          line = line.rstrip + query
          output_file.puts line
        end
      end
      input_file.close
      output_file.close
      
      # split the rule by "=>"
      text = File.read("#{dir}/rules/apriori_rules.txt")
      replace = text.gsub(" => ", "|")
      File.open("#{dir}/rules/apriori_rules.txt", "w") {|file| file.puts replace}
      File.delete("apriori_rules_temp.txt")

      #apply Eclat algorithm to mine association rules
      #r.eval <<-EOF
      #  ec_rules <- eclat(trans, parameter = list(supp = support_value, maxlen = maxlength, minlen = 2))
      #  summary(ec_rules)
      
      #  #output all mined rules and summary using Eclat algorithm ordered by lift into text file
      #  sink("ec_rules.txt", append=FALSE, split=FALSE)
      #  summary(ec_rules)
      #  inspect(sort(ec_rules, by="lift"))
      #  sink()
      #EOF
    
      puts "==> Rules have been saved to \"#{dir}/rules\""
      puts "==>     apriori_rules.txt"
      puts "\n"
      
      puts "*** RULE MINING - VISUALIZATION
*** Please specify number of groups and rules for visualization of rules." + "\n\n"

      #create a new pdf file to save the scatter plot with all mined rules. x is support, y is lift and shading represents confidence
      r.eval <<-EOF
        pdf("#{dir}/rules/scatter_plot.pdf")
        plot(apriori_rules, mainmeasure=c("support","chiSquare"),shading="chiSquare")
        dev.off()
      EOF
      puts "==> Graphs saved to \"#{dir}/rules\""
      puts "==>     scatter_plot.pdf"
      
      #create and save matrix-based plot
      r.eval <<-EOF
        pdf("#{dir}/rules/matrix_plot.pdf")
        plot(apriori_rules, method="matrix",measure="chiSquare",control=list(reorder=TRUE))
        dev.off()
      EOF
      puts "==>     matrix_plot.pdf"
    
      # user input k value
      puts "\n"
      k_value = inputNum("Enter the k value for plotting grouped matrix (integer > 0): ", "grouped_matrix_k")
      puts "\n"
      
      # create and save grouped matrix-based plot, default k=10.
      r.eval <<-EOF
        pdf("#{dir}/rules/grouped_matrix.pdf")
        plot(apriori_rules, method="grouped", measure="support", shading="chiSquare",control=list(k=#{k_value}))
        dev.off()
      EOF
      puts "==> Graph saved to \"#{dir}/rules\""
      puts "==>     grouped_matrix.pdf"
    
      # get a subset of rules for graph-based visualization
      # user input how many rules to be visualized
      puts "\n"
      subrules_num = inputNum("Enter the number of rules for plotting graphs (integer > 0): ", "rule_num")
      puts "\n"
      r.eval <<-EOF
        subrules <- head(sort(apriori_rules, by="chiSquare"), #{subrules_num})
      EOF
    
      #create and save graph-based plot using a subset of rules, with itemsets as vertices.
      #Limited to a small set of rules, user-input number is the same as above
      r.eval <<-EOF
        pdf("#{dir}/rules/graph_itemsets_as_vertices.pdf")
        plot(subrules, method="graph", shading="chiSquare", control=list(cex=1, alpha=1))
        dev.off()
      EOF
    
      #create and save graph-based plot using a subset of rules, with items and rules as vertices.
      #Limited to a small set of rules, user-input number is the same as above
      r.eval <<-EOF
        pdf("#{dir}/rules/graph_item_and_rules_as_vertices.pdf")
        plot(subrules, method="graph", shading="chiSquare", control=list(type="items", cex=1))
        dev.off()
      EOF
    
      #create and save graph-based plot using a large set of rules.
      #1000 rules will be graphed by default
      r.eval <<-EOF
        saveAsGraph(head(sort(apriori_rules, by="chiSquare"), 1000), file="#{dir}/rules/graph_large_set.graphml")
      EOF
      puts "==> Graphs saved to \"#{dir}/rules\""
      puts "==>     graph_itemsets_as_vertices.pdf"
      puts "==>     graph_item_and_rules_as_vertices.pdf"
      puts "==>     graph_large_set.graphml (use Gephi to view)"
    
      #r.eval "traceback()" 
        
      # another round of rule-mining if needed
      puts "\n"
      puts "**************************************************************"
      ans = prompt "Mine rules with different support/confidence settings? (y/n): "
      while ans !~ /\S/ or (ans.casecmp('y') != 0 and ans.casecmp('n') != 0)
        ans = prompt "Mine rules with different support/confidence settings? (y/n): "
      end
      if ans.casecmp("y") == 0
        mineRules(dir, r)
      end
      
    # Show warning if 0 rule is found, and mine rules again
    else
      puts "!!!!! WARNING: 0 rules found!"
      puts ">>>>> Mine rules again with different support and confidence values\n\n"
      
      mineRules(dir, r)
    end
    
    # update the log file.
    if (!File.exists?("#{dir}/log.txt"))
      File.new("#{dir}/log.txt")
    end
    log = File.open("#{dir}/log.txt", "a")
    time = Time.utc(*Time.new.to_a)
    log.puts "#{time} |Rule mining| Support: #{support_value} | Confidence: #{confidence_value} | Maxlength: #{maxlength} | #{r.num_rules} rules found"
    log.close
    
  # if filtered_mesh.txt doesn't exist or doesn't contain any rules, Show Error, program stops
  else
    puts "!!!!! ERROR in mineRules : filtered MeSH file does not exist!\n"
  end
    
end

#extractMeSH("C:/workspace/PubMedMinerCL/new1")
#------------------------Main program--------------------------

# user select which mode to run
puts "**********************************************************************************
*                PubMedMiner (Version 1.5)                                       *
*                                                                                *
* Choose one of the following modes:                                             *
*                                                                                *
* Main Modes:                                                                    *
*   1 - search, filter, and rule mining (includes statistics)                    *
*   2 - filter and rule mining (includes statistics)                             *
*   3 - rule mining only                                                         *
*                                                                                *
* Other Modes:                                                                   *
*   4 - search only                                                              *
*   5 - filter only                                                              *
*   6 - statistics only (before filtering)                                       *
*   7 - statistics only (after filtering)                                        *
*                                                                                *
**********************************************************************************

"

mode = prompt "Enter mode (1-7): "
mode = mode.to_i
puts "\n"

while mode > 7 or mode < 1
  mode = prompt "Enter mode (1-7): "
  mode = mode.to_i
  puts "\n"
end

# user specifies which directory to save generated files    
dir = specifyDir

if (mode == 1)
  searchIsSuccessful = search(dir)
  if (searchIsSuccessful == true)
    require 'rinruby'
    r=RinRuby.new(:echo=>false)

    statistics_all(dir, r)
    filter(dir)
    statistics_filtered(dir, r)
    mineRules(dir, r)
  else 
    puts "!!!!! ERROR: PubMed search failed"
  end
elsif (mode == 2)
  require 'rinruby'
  r=RinRuby.new(:echo=>false)
  
  filter(dir)
  statistics_filtered(dir, r)
  mineRules(dir, r)

elsif (mode == 3)
  require 'rinruby'
  r=RinRuby.new(:echo=>false)
  mineRules(dir, r)
    
elsif (mode == 4)
  
  searchIsSuccessful = search(dir)
  if (!searchIsSuccessful)
    puts "!!!!! ERROR: PubMed search failed"    
  else
    require 'rinruby'
    r=RinRuby.new(:echo=>false)
    statistics_all(dir, r)
  end
elsif (mode == 5)
  filter(dir)
  require 'rinruby'
  r=RinRuby.new(:echo=>false)
  statistics_filtered(dir, r)

elsif (mode == 6)
  require 'rinruby'
  r=RinRuby.new(:echo=>false)
  statistics_all(dir, r)
  
elsif (mode == 7)
  require 'rinruby'
  r=RinRuby.new(:echo=>false)
  statistics_filtered(dir, r)
end
