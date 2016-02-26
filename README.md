###Linkage_Parser
_____________________________________________________

This class is trying to parsing a .txt file into four data structures as we need. Multi-page reading and parsing is supported. 

###Supported operating systems

should install on pretty much any recent Linux or OSX operating system.

###Integration to the product

This module/class can be just moved to the project to use and also it can be executed alone:

####Running

With valid commands from the input file:

$ ruby main.rb input/test.txt

Welcome to Linkage Parser

parcels: [{:plan_number=>"DP568779", :lot_ids=>["2"], :linkage_indexes=>[0]}, {:plan_number=>"DP592644", :lot_ids=>["1"], :linkage_indexes=>[0]}, {:plan_number=>"DP701190", :lot_ids=>["1182"], :linkage_indexes=>[1]}, {:plan_number=>"DP814134", :lot_ids=>["11"], :linkage_indexes=>[0]}, {:plan_number=>"DP863427", :lot_ids=>["11"], :linkage_indexes=>[2, 3]}, {:plan_number=>"DP873840", :lot_ids=>["41"], :linkage_indexes=>[4]}, {:plan_number=>"DP884319", :lot_ids=>["21"], :linkage_indexes=>[5, 6]}, {:plan_number=>"DP1004944", :lot_ids=>["1", "2", "3"], :linkage_indexes=>[7]}, {:plan_number=>"DP1014491", :lot_ids=>["21", "22"], :linkage_indexes=>[8]}, {:plan_number=>"DP1015464", :lot_ids=>["1", "2", "3", "4", "5", "6"], :linkage_indexes=>[9]}, {:plan_number=>"DP1031456", :lot_ids=>["10"], :linkage_indexes=>[10, 11, 12]}, {:plan_number=>"DP1035020", :lot_ids=>["10"], :linkage_indexes=>[3]}, {:lot_ids=>["8", "9", "10"], :plan_number=>"DP1035020", :linkage_indexes=>[7, 2]}, {:plan_number=>"DP1045370", :lot_ids=>["13", "14"], :linkage_indexes=>[13]}, {:plan_number=>"DP1047039", :lot_ids=>["271"], :linkage_indexes=>[14]}, {:plan_number=>"DP1047185", :lot_ids=>["105"], :linkage_indexes=>[7, 2, 15]}, {:plan_number=>"DP1056728", :lot_ids=>["12", "13", "14", "15", "16", "20"], :linkage_indexes=>[15, 3]}, {:lot_ids=>["12", "13", "14", "15", "16", "17", "20"], :plan_number=>"DP1056728", :linkage_indexes=>[7, 2]}]

linkages: [{:linked_plan_number=>"DP1167490", :status=>"REGISTERED", :surv_comp=>"SURVEY", :purpose=>"RESUMPTION OR ACQUISITION", :parcel_indexes=>[0, 1, 3]}, {:linked_plan_number=>"DP1154461", :status=>"REGISTERED", :surv_comp=>"SURVEY", :purpose=>"SUBDIVISION", :parcel_indexes=>[2]}, {:linked_plan_number=>"DP1004944", :status=>"REGISTERED", :surv_comp=>"SURVEY", :purpose=>"SUBDIVISION", :parcel_indexes=>[4, 12, 15, 17]}, {:linked_plan_number=>"DP1047185", :status=>"REGISTERED", :surv_comp=>"SURVEY", :purpose=>"SUBDIVISION", :parcel_indexes=>[4, 11, 16]}, {:linked_plan_number=>"DP1056287", :status=>"REGISTERED", :surv_comp=>"COMPILATION", :purpose=>"EASEMENT", :parcel_indexes=>[5]}, {:linked_plan_number=>"DP418693", :status=>"HISTORICAL", :surv_comp=>"SURVEY", :purpose=>"UNRESEARCHED", :parcel_indexes=>[6]}, {:linked_plan_number=>"DP840115", :status=>"HISTORICAL", :surv_comp=>"SURVEY", :purpose=>"SUBDIVISION", :parcel_indexes=>[6]}, {:linked_plan_number=>"DP863427", :status=>"HISTORICAL", :surv_comp=>"SURVEY", :purpose=>"SUBDIVISION", :parcel_indexes=>[7, 12, 15, 17]}, {:linked_plan_number=>"DP508851", :status=>"HISTORICAL", :surv_comp=>"SURVEY", :purpose=>"SUBDIVISION", :parcel_indexes=>[8]}, {:linked_plan_number=>"DP868431", :status=>"HISTORICAL", :surv_comp=>"SURVEY", :purpose=>"SUBDIVISION", :parcel_indexes=>[9]}, {:linked_plan_number=>"DP551785", :status=>"HISTORICAL", :surv_comp=>"SURVEY", :purpose=>"SUBDIVISION", :parcel_indexes=>[10]}, {:linked_plan_number=>"DP577470", :status=>"HISTORICAL", :surv_comp=>"SURVEY", :purpose=>"SUBDIVISION", :parcel_indexes=>[10]}, {:linked_plan_number=>"DP1015037", :status=>"REGISTERED", :surv_comp=>"SURVEY", :purpose=>"SUBDIVISION", :parcel_indexes=>[10]}, {:linked_plan_number=>"DP862896", :status=>"HISTORICAL", :surv_comp=>"SURVEY", :purpose=>"SUBDIVISION", :parcel_indexes=>[13]}, {:linked_plan_number=>"DP177967", :status=>"HISTORICAL", :surv_comp=>"SURVEY", :purpose=>"UNRESEARCHED", :parcel_indexes=>[14]}, {:linked_plan_number=>"DP1035020", :status=>"REGISTERED", :surv_comp=>"SURVEY", :purpose=>"SUBDIVISION", :parcel_indexes=>[15, 16]}]

polygons: []

text_notations: []

parcels.size: 18

linkages.size: 16


###Development notes

In order to get the text_notation correctly, before we parse, have to delete the header and tail of the txt file.

Usually the sign of the header is like "Status                       Surv/Comp                Purpose", and this is the only case. 

For the tail: there could be 2 cases: starting like:  "Caution:      For all ACTIVITY PRIOR to SEPT 2002 you must refer to the RGs Charting and Reference Maps." 
or "blah". Will get all the indexes of those cases, then sort them and get the content between each 2 indexes(one page has 2 indexes). So there must be even number of indexes. 


Four data structures will be used to store the data parsed from the input file: 
The 2 data structures like parcels and polygons both have indexes of linkages and text_notations, and vice versa. 

Parcel: 
parcels: [{ plan_number: string, lot_ids: array, section_ids: array, linkage_indexes: array, text_notation_indexes: array}, {}, {}...]


Parcel_Polygons: 

polygons: [{polygon_type: type, polygon_id: string, linkage_indexes: array, text_notation_indexes: array}, {}, {}]

Linkage: 
linkages: [{linked_plan_number: string, status: string, surv_comp: string, purpose: string, parcel_indexes: array, polygon_indexes: array}, {}, {}..]

Text notation: 
text_notations: [{text: string, parcel_indexes: array, polygon_indexes: array}, {}, {}...]

###Supported Ruby Versions
Ruby 2.16

###Contact

Judy Wu, judy.wu#urbispro.com.au
