PubMedMiner: Mining and Visualizing MeSH-based Associations in PubMed
2014-03-09
Author: Yucan Zhang

******************************Project Description************************************
Project Description:
For a given PubMed search, the pipeline retrieves MEDLINE records, extracts MeSH terms and allows for filtering of 
MeSH terms according to user-specified UMLS semantic type(s). Basic statistics for each MeSH term and UMLS semantic type
are displayed in both tabular and graphical formats. Association rules among MeSH terms are generated and visualized using 
the "arules" and "arulesViz" R packages.


*********************************Dependencies****************************************

Dependencies:
 - Ruby
The programming language used for this program.
Ruby can be downloaded from the following link:
https://www.ruby-lang.org/en/

 - RubyGems
The RubyGems software allows you to easily download, install, and use ruby software packages on your system. 
The software package is called a "gem" and contains a package Ruby application or library. 
For Ruby 1.9 and newer, RubyGems is built in.
Otherwise, download RubyGems from following link:
http://rubygems.org/

Gems needed for this program include:
 - bio
BioRuby is a library for bioinformatics (biology + information science).
It provides methods to interact with NCBI PubMed/MEDLINE database, NCBI E-Utilities for this program in particular.
The gem 'bio' can be downloaded following this link:
http://rubygems.org/gems/bio

 - yaml
The 'yaml' gem provides access to the YAML file as a lookup for Ruby.
It is integrated in the Ruby 1.9.2 or newer.
Otherwise, download one of the YAML for Ruby from:
http://yaml.org/

 - rinruby
RinRuby is a Ruby library that integrates the R interpreter in Ruby, 
making R's statistical routines and graphics available within Ruby.
Downloadable from:
http://rubygems.org/gems/rinruby

 - NCBI E-Utilities
The Entrez Programming Utilities (E-Utilities) are a set of programs that translate a standard set of input parameters
into the values necessary for various NCBI components to search for and retrieve the requested data.
http://www.ncbi.nlm.nih.gov/books/NBK25497/
Two utilities are used in this program:
 * esearch: search specified database with text query, return the number or the list of UIDs matching the query
 * efetch: with the list of UIDs, retrieve data records in specified format from the database
See more information about different utilities at:
http://www.ncbi.nlm.nih.gov/books/NBK25500/

**** In order to correctly use the NCBI E-Utilities, a default email address is required in the script.
**** At line #109 in the PubMedMiner.rb script file, replace xxxx@xxx.xxx with a working email address.

 - R
Language and environment for statistical computing and graphics.
Can be downloaded at:
http://www.r-project.org/

R packages are collections of R functions, data, and compiled code in a well-defined format.
Two R packages are used in this program:
 - arules: for frequency counting and association rule mining among input data (MeSH terms in this program)
Downloadable at: http://cran.r-project.org/web/packages/arules/index.html
 - arulesViz: for visualizing generated association rules in various types of graphs
Downloadable at: http://cran.r-project.org/web/packages/arulesViz/index.html

Other software for viewing graphs are:
 - Adobe Reader for PDF files
Downloadable at: http://get.adobe.com/reader/

 - Gephi for graphml files
Downloadable at: https://gephi.org/
 
 
*********************************Required Files**************************************

Required Files:
*******Scripts:
 - create_mesh_ST_file.rb: This script file creates the MeSH_ST.yml file required by the main program.
     It uses MeSH descriptors in the "d2013.bin" file and semantic types in the "SemGroups.txt" file,
     creates a hash table with MeSH descriptors as the key and corresponding semantic types as values, 
     and stores the hash table in the "MeSH_ST.txt" file
 - PubMedMiner.rb: Main Ruby script file with all codes for the progrom.
*******Text Files:
 - d2013.bin: 2013 MeSH descriptors in ASCII format downloaded from U.S. National Library of Medicine (http://www.nlm.nih.gov/mesh/filelist.html).
   	 If a new version is available, for example, 2014 MeSH descriptor in ASCII format, download the d2014.bin, 
     change the file name "d2013.bin" in the create_mesh_ST_file.rb to "d2014.bin" with correct directory path, 
     and then run the create_mesh_ST_file.rb to convert MeSH descriptors into the format that is appropriate for the PubMedMiner program.
 - SemGroups.txt: UMLS Semantic Groups file downloaded from NLM (http://semanticnetwork.nlm.nih.gov/SemGroups/)
 - MeSH_ST.yml: This file stores the MeSH:Semantic types hash table created by the "create_mesh_ST_file.rb".


***********************************Output Files**************************************

*In the specified main folder:
 - log.txt:
     Records information of each modification on files in this folder.
     
Output Files Required for Statistical Analysis and Rule Mining:

*In the data subfolder:
 - pubmed_result.txt: stores MEDLINE records retrieved from PubMed using user specified search key
     See the MEDLINE record format following this link: http://www.nlm.nih.gov/bsd/mms/medlineelements.html
 - PMID_MeSH.txt: stores PMID and associated MeSH terms
     Format: PMID|MeSH1^MeSH2^...^MeSHn^
     
*In the mesh subfolder:
 - extracted_mesh.txt: stores all MeSH terms extracted from PMID_MeSH.txt.
     PMIDs without MeSH terms are removed.
     Format (one MeSH term per line): 
     PMID|MeSH1
     PMID|MeSH2
     Single quotation marks in MeSH terms are surrounded by double quotation marks for importing into R.
 - filtered_mesh.txt: Stores the MeSH terms matching user specified semantic type(s).
     This file will be uploaded as transactions for rule mining.
     The format is the same as extracted_mesh.txt.
 
Output Files:

*In the mesh subfolder:
 - mesh_term_statistics.txt: 
 	stores the absolute count and relative frequency of each MeSH term.
	Format: mesh_term|absolute_count|relative_frequency|semantic_type
 - mesh_term_count.pdf: 
 	histogram of absolute count of top N MeSH terms. N is user-specified.
 - mesh_term_frequency.pdf: 
 	histogram of relative frequency of top N MeSH terms. N is user-specified.
 	
 - filtered_mesh_term_statistics.txt:
    stores the absolute count and relative frequency of each filtered MeSH term.
    Format: filtered_mesh_term|absolute_count|relative_frequency|semantic_type
 - filtered_mesh_term_count.pdf
    histogram of absolute count of top N filtered MeSH terms. N is user-specified.
 - filtered_mesh_term_frequency.pdf:
    histogram of relative frequency of top N filtered MeSH terms. N is user-specified.
 	
 	
*In the semantic_types subfolder:
 - semantic_type_statistics.txt: 
 	stores the absolute count and relative frequency of each semanticy type.
 	Format: semantic_type|count(with dup)|relative_freq(with dup)|count(without dup)|relative_freq(without dup)
 - semantic_type_count_including_duplicates.pdf: 
 	histogram of absolute count of top N semantic types.
	Duplicated semantic types associated with the same PMID are included. N is user-specified.
 - semantic_type_frequency_including_duplicates.pdf: histogram of relative frequency of top N semantic types.
    Duplicated semantic types associated with the same PMID are included. N is user-specified.
 - semantic_type_count_without_duplicates.pdf: 
 	histogram of absolute count of top N semantic types.
	Duplicated semantic types associated with the same PMID are removed. N is user-specified.
 - semantic_type_frequency_without_duplicates.pdf: 
 	histogram of relative frequency of top N semantic types.
	Duplicated semantic types associated with the same PMID are removed. N is user-specified.

 - filtered_semantic_type_statistics.txt
 	stores the absolute count and relative frequency of semanticy type corresponding to each filtered MeSH term.
 	Format: filtered_semantic_type|count(with dup)|relative_freq(with dup)|count(without dup)|relative_freq(without dup)
 - filtered_semantic_type_count_including_duplicates.pdf: 
 	histogram of absolute count of top N semantic types matching filtered MeSH terms.
	Duplicated semantic types associated with the same PMID are included. N is user-specified.
 - filtered_semantic_type_frequency_including_duplicates.pdf: 
    histogram of relative frequency of top N semantic types matching filtered MeSH terms.
    Duplicated semantic types associated with the same PMID are included. N is user-specified.
 - filtered_semantic_type_count_without_duplicates.pdf: 
 	histogram of absolute count of top N semantic types matching filtered MeSH terms.
	Duplicated semantic types associated with the same PMID are removed. N is user-specified.
 - filtered_semantic_type_frequency_without_duplicates.pdf: 
 	histogram of relative frequency of top N semantic types matching filtered MeSH terms.
	Duplicated semantic types associated with the same PMID are removed. N is user-specified.


*In the rules subfolder:
 - apriori_rules.txt: 
 	stores the association rules among MeSH terms associated with user-specified semantic type(s).
	It also contains the PubMed Query containing both sides of the rule.
	All the rules are ordered according to the chiSquare value.
	Format: lhs|rhs|support|confidence|lift|chiSquare|conviction|cosine|coverage|doc|hyperLift|hyperConfidence|fishersExactTest|gini|improvement|leverage|oddsRatio|phi|RLD|PubMed query
	Example: {[Eosinophilia]}|{[Asthma]}|0.0212616588105506|0.990654205607477|1.01917179984649|2.79235840050618|2.99398254939322|0.147204901676781|0.0214622404974426|0.0190440795441373|0.995305164319249|0.941886754709824|0.0581132452901763|1.52336023587101e-05|Inf|0.000399956383390476|3.09725738396622|0.0167346341217927|0.665996717247846|http://www.ncbi.nlm.nih.gov/pubmed/?term="Eosinophilia"[mh] and "Asthma"[mh]

 - scatter_plot.pdf: 
 	scatter plot of mined association rules. 
	x is support, y is chiSquare and shading represents confidence.
	
 - matrix_plot.pdf: 
 	matrix plot of mined association rules.
	x is antecedent (LHS) of the rule and y is consequent (RHS). Shading represents chiSquare.
 
 - grouped_matrix.pdf: 
 	grouped matrix plot of mined association rules.
	x is antecedent (LHS) and y is consequent (RHS). Size and color represent support and chiSquare respectively.
 
 - graph_itemsets_as_vertices.pdf: 
 	Graph for top N association rules. 
	N is a relatively small integer (<50) specified by user.
	Vertices are sets of MeSH terms and edges are association rules.
	Width and size of the edges represent support and chiSquare respectively.
 
 - graph_item_and_rules_as_vertices.pdf: 
 	Graph for top N association rules. 
	N is a relatively small integer (<50) specified by user.
	MeSH terms and rules are both vertices. Rules are represented by circles. 
	Size and color of the circle represent support and chiSquare respectively.
 
 - graph_large_set.graphml: 
 	graph-based plot for a large set of rules (1000 rules by default).
	This .graphml file has to be viewed by Gephi.
    
    
**************************************Instructions**************************************

Instructions:
*** create MeSH_ST.yml file by running create_mesh_ST_file.rb
    "MeSH_ST.yml" is required for running the program. It is converted from the MeSH descriptor file (in the ASCII format) downloaded from NLM.
The "MeSH_ST.yml" in current package uses "d2013.bin". If a new version is available, for example, 2014 MeSH descriptor in ASCII format, download the "d2014.bin", 
change the file name "d2013.bin" in the create_mesh_ST_file.rb to "d2014.bin" with correct directory path, 
and then run the "create_mesh_ST_file.rb" to convert MeSH descriptors into "MeSH_ST.yml" file that is required by the PubMedMiner program.
The "create_mesh_ST_file.rb" only needs to run once when there is a newer version of MeSH descriptor file available.

Run this script as follows:
$ ruby create_mesh_ST_file.rb

*** Main program
Run the main program as follows:
$ ruby PubMedMiner.rb

1.	The program then asks which mode to run.
There are four main functions for data collecting and analysis: search, statistics, filter and mine_rules.
 - search: searches PubMed with specified query, retrieves MEDLINE records
 - statistics: counts the occurrence of each MeSH term and semantic type
 - filter: filters MeSH terms based on specified semantic type(s)
 - mine_rules: generates and visualizes association rules among filtered MeSH terms
User can run them separately or in different combinations by specifying the run mode below.

===============
Choose one of the following modes:
Main Modes:
1 - search, filter, and rule mining (includes statistics)
### Runs through all main functions step by step.
### searches and retrieves MEDLINE records, counts frequency of each MeSH term and semantic type
### filters retrieved MeSH terms, statistics on filtered MeSH terms
### generates and visualizes association rules among filtered MeSH terms
2 - filter and rule mining (includes statistics)
### first filters the MeSH terms based on input semantic type(s), counts frequency of each MeSH term and semantic type,
### then generates and visualizes association rules among filtered MeSH terms
3 - rule mining only
### only generates and visualizes association rules using MeSH terms filtered in previous run

Other Modes:
4 - search only
### searches and retrieves MEDLINE records matching specified query
### counts frequency of each retrieved MeSH term and semantic type
5 - filter only
### filters the MeSH terms based on input semantic type(s)
### counts frequency of filtered MeSH terms and semantic types
6 - statistics only (before filtering)
### counts and displays the frequency of filtered MeSH terms and semantic types
7 - statistics only (after filtering)
### counts and displays the frequency of retrieved MeSH terms and semantic types

===============
Each mode will check if required files exist in specified directory. 
If not, run the appropriate function to create required files first or show ERROR message.

2.	The program gives the current working directory and asks for full path to save all output files.
If the input directory does not exist, the program will create the directory and save all output files into it.
If the directory is unspecified, the program will save all files in the "results" folder in the current working directory.

3.  Following are descriptions of major functions in the main program.
All files created by functions will be saved in the user-specified directory passed by argument (dir).

=== 3.1. search(dir)
Asks key words for searching in Pubmed and fetches all matched records using NCBI E-Utilities, 
saves in "pubmed_result.txt" and reformats all records in "PMID_MeSH.txt" with only PMID and mesh terms.

---------------
Creates:
pubmed_result.txt
PMID_MeSH.txt
---------------

=== 3.2. extractMeSH(dir)
Further extracts MeSH headings from PMID_MeSH.txt and removes MeSH subheadings.
Formats all MeSH terms as two columns of PMID-MeSH pairs (get ready for being uploaded into R as transactions)

---------------
Requires:
MeSH_ST.yml
PMID_MeSH.txt

Creates:
extracted_mesh.txt
---------------

=== 3.3. convertToSemT(dir)
Converts MeSH terms into corresponding semantic types.

Since multiple MeSH terms might point to the same semantic type, 
the same semantic type might appear multiple times within one MEDLINE record.
Thus, stores semantic types in two formats:
 1) extracted_semantic_types.txt: 
    PMID-SemT pairs for calculating SemT frequency excluding duplicates related to a single PMID
 2) extracted_semantic_types_only.txt:
    SemT only (without PMID) for calculating frequency including duplicates

---------------
Requires:
extracted_mesh.txt
MeSH_ST.yml

Creates:
extracted_semantic_types.txt
extracted_semantic_types_only.txt
---------------

=== 3.4. statistics_all(dir, r)
Count occurrence of retrieved MeSH terms and semantic types. 
Both absolute count and relative frequency are saved in tabular foramt and visulized using histogram.
"dir" specifies where all generated files will be saved to.
"r" specifies the rinruby object created in the main program.

Since multiple MeSH terms might point to the same semantic type, 
the same semantic type might appear multiple times within one MEDLINE record.
Thus, semantic type counting is implemented with and without duplicates.

---------------
Requires:
extracted_mesh.txt
extracted_semantic_types.txt (deleted after use)
extracted_semantic_types_only.txt (deleted after use)

Creates:
mesh_term_count.pdf
mesh_term_frequency.pdf
mesh_term_statistics.txt
semantic_type_count_without_duplicates.pdf
semantic_type_frequency_without_duplicates.pdf
semantic_type_count_including_duplicates.pdf
semantic_type_frequency_including_duplicates.pdf
semantic_type_statistics.txt
---------------

=== 3.5. filter(dir)
Ask semantic type(s) for filtering MeSH terms. 
Type in "all" if all semantic types are desired. 
Or type in one or more semantic type descriptions (case-insensitive) separated by "|".
Filtered records are saved in "filtered_MeSH.txt".

# If "all", no need to filter, just save all MeSH terms from "extracted_mesh.txt" into "filtered_MeSH.txt"
# If one or more semantic type(s) are entered, filter the "extracted_mesh.txt" file and select MeSH terms matching input semantic types.
  Then remove the single quotation marks from filtered MeSH terms.
  
---------------
Requires:
MeSH_ST.yml
extracted_mesh.txt

Creates:
filtered_mesh.txt
---------------

=== 3.6. convert_filtered_mesh_to_sem(dir)
Converts filtered MeSH terms to corresponding semantic types.

---------------
Requires:
MeSH_ST.yml
filtered_mesh.txt

Creates:
filtered_semantic_types.txt
filtered_semantic_types_only.txt
---------------

=== 3.7. statistics_filtered(dir, r)
Count occurrence of filtered MeSH terms and semantic types. 
Both absolute count and relative frequency are saved in tabular foramt and visulized using histogram.
Semantic type counting is implemented with and without duplicates.
"dir" specifies where all generated files will be saved to.
"r" specifies the rinruby object created in the main program.

---------------
Requires:
filtered_mesh.txt
filtered_semantic_types.txt (deleted after use)
filtered_semantic_types_only.txt (deleted after use)

Creates:
filtered_mesh_term_count.pdf
filtered_mesh_term_frequency.pdf
filtered_mesh_term_statistics.txt
filtered_semantic_type_count_without_duplicates.pdf
filtered_semantic_type_frequency_without_duplicates.pdf
filtered_semantic_type_count_including_duplicates.pdf
filtered_semantic_type_frequency_including_duplicates.pdf
filtered_semantic_type_statistics.txt
---------------

=== 3.8. mineRules(dir, r)
Asks for a set of parameters for association rule mining.
Generates association rules among filtered MeSH terms using R with "arules" package.
Creates a number of types of plots based on mined rules using R with "arulesViz" package. 

Questions will be asked are as follows:

�	Enter support value (decimal between 0.0 and 1.0): 
�	Enter confidence value (decimal between 0.0 and 1.0):
�	Enter the maximum length for rules (integer >= 2):
These three parameters are required for mining rules using apriori algorithm. 
They determine the number of rules we can get at the end.
The "scatter_plot.jpg", "matrix_plot.jpg" will be created without more questions.

�	Enter the k value for plotting grouped matrix (integer > 0): 
This question is for grouped matrix.
k-value represents the number of groups will be plotted on the LHS. 
The default value in arulesViz is 10.
The "grouped_matrix.jpg" will be created after this input.

�	Enter the number of rules for plotting graphs (integer > 0):
This question is for graph-based visualization. 
"arulesViz" can only handle a small set of rules with this function. 
Although it is not clear what the maximum number of rules can be graphed, based on the clarity of the graph, somewhere below 50 might be a good guess. 
Otherwise, it is difficult to see the characters on the graphs.
"graph_itemsets_as_vertices.jpg", and "graph_item_and_rules_as_vertices.jpg" are created after this input.

To handle large set of rules, "graph_large_set.graphml" is created and can be viewd in Gephi. 
The default number is 1000. It can be changed in the source code. It can be implemented in the future in such way that the user can set this number.

So far, all plots are created using inputs from the user. One more question will be asked:
�	Mine rules with different support/confidence settings? (y/n)
If "y", the mineRules function will run again. All the .pdf files will be rewritten with new inputs.
If "n", the program will stop.

If the user want to change the key words for searching pubmed, the script needs to be re-run from the beginning.

---------------
Requires:
filtered_mesh.txt

Creates:
apriori_rules.txt
scatter_plot.pdf
matrix_plot.pdf
grouped_matrix.pdf
graph_itemsets_as_vertices.pdf
graph_item_and_rules_as_vertices.pdf
graph_large_set.graphml
---------------


*********************************Demonstration**************************************

1. Run the "PubMedMiner.rb":
$ ruby PubMedMiner.rb

**********************************************************************************
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

Enter mode (1-7): 1

*** The current working directory is C:/workspace/PubMedMinerCL1.4
*** By default, all generated files be stored in the "results" folder in this directory.
*** For a different directory, please specify the full path. 
*** (Note: a new folder will be automatically created if the directory does not exist)

Enter full path of directory: C:/workspace/PubMedMinerCL1.4/Example

*** SEARCH
*** Please specify a PubMed search.
*** Example: "university of vermont"[ad] and "diabetes mellitus"[mh]
*** For a tutorial, see http://www.nlm.nih.gov/bsd/disted/pubmedtutorial/cover.html

Enter PubMed search: "university of vermont"[ad] and "diabetes mellitus"[mh]

==> 181 publications have been found for this search
==> MEDLINE records have been retrieved into "C:/workspace/PubMedMinerCL1.4/Example/data"
==> PMID and MeSH terms have been extracted and reformatted into "C:/workspace/PubMedMinerCL1.4/Example/data"

DL is deprecated, please use Fiddle
*** STATISTICS
*** Basic statistics for all MeSH terms and semantic types will be calculated.
*** For graphs, please specify number to be displayed (top 10, top 20, etc.)

Enter the number of MeSH terms to be displayed in graphs (integer > 0): 20

Enter the number of semantic types to be displayed in graphs (integer > 0): 20

==> MeSH statistics and graphs saved to "C:/workspace/PubMedMinerCL1.4/Example/mesh"
==> Semantic type statistics and graphs saved to "C:/workspace/PubMedMinerCL1.4/Example/semantic_types"

*** FILTER BY SEMANTIC TYPE(S)
*** Please specify semantic type(s) to filter by or "all" to keep all semantic types.
*** Example: Disease or Syndrome|Mental or Behavioral Dysfunction|Neoplastic Process
*** For complete list, see http://www.nlm.nih.gov/research/umls/META3_current_semantic_types.html
*** or select based on results in "C:/workspace/PubMedMinerCL1.4/Example/semantic_types"

Enter semantic type(s) separated by '|': all

==> PMID and MeSH terms have been filtered in "C:/workspace/PubMedMinerCL1.4/Example/data"

*** STATISTICS AFTER FILTERING
*** Basic statistics for filtered MeSH terms and semantic types will be calculated.
*** For graphs, please specify number to be displayed (top 10, top 20, etc.)

Enter the number of MeSH terms to be displayed in graphs (integer > 0): 20

Enter the number of semantic types to be displayed in graphs (integer > 0): 20

==> MeSH statistics and graphs saved to "C:/workspace/PubMedMinerCL1.4/Example/mesh"
==> Semantic type statistics and graphs saved to "C:/workspace/PubMedMinerCL1.4/Example/semantic_types"

*** RULE MINING - GENERATION
*** Please specify support and confidence values to use as cutoffs as well as 
*** the maximum length of rules.

Enter support value (decimal between 0.0 and 1.0): 0.1

Enter confidence value (decimal between 0.0 and 1.0): 0.8

Enter the maximum length for rules (integer >= 2): 5

==> Rules have been saved to "C:/workspace/PubMedMinerCL1.4/Example/rules"
==>     apriori_rules.txt

*** RULE MINING - VISUALIZATION
*** Please specify number of groups and rules for visualization of rules.

==> Graphs saved to "C:/workspace/PubMedMinerCL1.4/Example/rules"
==>     scatter_plot.pdf
==>     matrix_plot.pdf

Enter the k value for plotting grouped matrix (integer > 0): 20

==> Graph saved to "C:/workspace/PubMedMinerCL1.4/Example/rules"
==>     grouped_matrix.pdf

Enter the number of rules for plotting graphs (integer > 0): 20

==> Graphs saved to "C:/workspace/PubMedMinerCL1.4/Example/rules"
==>     graph_itemsets_as_vertices.pdf
==>     graph_item_and_rules_as_vertices.pdf
==>     graph_large_set.graphml (use Gephi to view)

**************************************************************
Mine rules with different support/confidence settings? (y/n): n


**** Notice: see sample output files in the "Example" folder
**** Output files include:
Example/

log.txt

===data/:
PMID_MeSH.txt
pubmed_result.txt

===mesh/:
extracted_mesh.txt
mesh_term_count.pdf
mesh_term_frequency.pdf
mesh_term_statistics.txt
filtered_mesh.txt
filtered_mesh_term_count.pdf
filtered_mesh_term_frequency.pdf
filtered_mesh_term_statistics.txt

===semantic_types/:
filtered_semantic_type_count_including_duplicates.pdf
filtered_semantic_type_count_without_duplicates.pdf
filtered_semantic_type_frequency_including_duplicates.pdf
filtered_semantic_type_frequency_without_duplicates.pdf
filtered_semantic_type_statistics.txt
semantic_type_count_including_duplicates.pdf
semantic_type_count_without_duplicates.pdf
semantic_type_frequency_including_duplicates.pdf
semantic_type_frequency_without_duplicates.pdf
semantic_type_statistics.txt

===rules/:
apriori_rules.txt
graph_item_and_rules_as_vertices.pdf
graph_itemsets_as_vertices.pdf
graph_large_set.graphml
grouped_matrix.pdf
matrix_plot.pdf
scatter_plot.pdf
