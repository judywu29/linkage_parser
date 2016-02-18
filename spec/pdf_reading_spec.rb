require 'spec_helper'
require_relative '../pdf_reading'

describe LinkageParser do
  let(:parser_test) { LinkageParser.new('./spec/input/test.txt')}
  describe "#initialize" do
    it "initializes an new instance with 'test.txt'file" do
      expect(parser_test).to be_a LinkageParser
      expect(parser_test.file).not_to be_nil

      expect(parser_test.parcels).to be_an Array
      expect(parser_test.polygons).to be_an Array
      expect(parser_test.linkages).to be_an Array
      expect(parser_test.text_notations).to be_an Array
    end

    it "puts the message that the file is unable to read" do
      expect{ LinkageParser.new('fake.txt') }.to output("Could not load file - No such file or directory @ rb_sysopen - fake.txt\n").to_stdout

    end
  end

  describe "#is_plan_number_line?" do
    context "with plan number line" do
      it "returns true" do
        result = parser_test.send :is_plan_number_line?, 'DP1199636'
        expect(result).to be_truthy
      end
      it "returns true" do
        result = parser_test.send :is_plan_number_line?, 'SP1199636'
        expect(result).to be_truthy
      end
    end
    context "not plan number line" do
      it "return false" do
        result = parser_test.send :is_plan_number_line?, 'DP177967              HISTORICAL            SURVEY                UNRESEARCHED'
        expect(result).to be_falsey
      end
      it "return false" do
        result = parser_test.send :is_plan_number_line?, 'Polygon Id(s): 171799813'
        expect(result).to be_falsey
      end
    end

  end

  describe "#is_lot_or_section_line?" do
    context "with lot or section line" do
      it "return true" do
        result = parser_test.send :is_lot_or_section_line?, 'Lot(s): 130'
        expect(result).to be_truthy
      end
      it "return true" do
        result = parser_test.send :is_lot_or_section_line?, 'Lot(s): 28, 30 Section : 2'
        expect(result).to be_truthy
      end
    end
    context "not lot or section line" do
      it "return false" do
        result = parser_test.send :is_lot_or_section_line?, ' 130'
        expect(result).to be_falsey
      end
    end
  end

  describe "#is_polygon_id_line?" do
    context "with polygon id line" do
      it "returns true" do
        result = parser_test.send :is_polygon_id_line?, 'Polygon Id(s): 171799813'
        expect(result).to be_truthy
      end
    end
    context "not polygon id line" do
      it "return false" do
        result = parser_test.send :is_polygon_id_line?, 'DP177967              HISTORICAL            SURVEY                UNRESEARCHED'
        expect(result).to be_falsey
      end
    end
  end

  describe "#is_polygon_type_line?" do
    context "with polygon type line" do
      it "returns true" do
        result = parser_test.send :is_polygon_type_line?, 'Water Feature'
        expect(result).to be_truthy
      end
      it "returns true" do
        result = parser_test.send :is_polygon_type_line?, 'Road'
        expect(result).to be_truthy
      end
      it "returns true" do
        result = parser_test.send :is_polygon_type_line?, 'Unidentified'
        expect(result).to be_truthy
      end
      it "returns true" do
        result = parser_test.send :is_polygon_type_line?, 'Intersection'
        expect(result).to be_truthy
      end
    end
    context "not polygon type line" do
      it "return false" do
        result = parser_test.send :is_polygon_type_line?, 'any random line'
        expect(result).to be_falsey
      end
      it "return false" do
        result = parser_test.send :is_polygon_type_line?, 'fake Water line'
        expect(result).to be_falsey
      end

    end
  end

  describe "#is_linkages_detail_line?" do
    context "with linkage detail line" do
      it "return true" do
        result = parser_test.send :is_linkages_detail_line?, 'DP177967              HISTORICAL            SURVEY                UNRESEARCHED'
        expect(result).to be_truthy
      end
    end
    context "not linkage detail line" do
      it "return false" do
        result = parser_test.send :is_linkages_detail_line?, 'DP177967'
        expect(result).to be_falsey
      end
    end
  end

  describe "#is_text_notation_line?" do
    context "with text notation line" do
      it "return true" do
        result = parser_test.send :is_text_notation_line?, 'NSW GAZ.                     22-02-2013                   Folio : 482'
        expect(result).to be_truthy
      end
    end
    context "not text notation line" do
      it "return false" do
        result = parser_test.send :is_text_notation_line?, 'DP177967'
        expect(result).to be_falsey
      end
      it "return false" do
        result = parser_test.send :is_text_notation_line?, ''
        expect(result).to be_falsey
      end
      it "return false" do
        result = parser_test.send :is_text_notation_line?, 'Road'
        expect(result).to be_falsey
      end
      it "return false" do
        result = parser_test.send :is_text_notation_line?, 'DP177967              HISTORICAL            SURVEY                UNRESEARCHED'
        expect(result).to be_falsey
      end
      it "return false" do
        result = parser_test.send :is_text_notation_line?, 'Lot(s): 130'
        expect(result).to be_falsey
      end
      it "return false" do
        result = parser_test.send :is_text_notation_line?, 'Polygon Id(s): 171799813'
        expect(result).to be_falsey
      end
    end
  end

  describe "#is_continued?" do
    context "endding with comma" do
      it "return true" do
        result = parser_test.send :is_continued?, '101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126,'
        expect(result).to be_truthy
      end
    end
    context "without comma at the end" do
      it "return false" do
        result = parser_test.send :is_continued?, '109, 110, 111, 112, 118, 119, 120, 121, 126, 127, 128, 129, 130, 151, 152, 153, 175'
        expect(result).to be_falsey
      end
    end
  end

  describe "#load_plan_number" do
    it "addes plan_number to @parcels" do
      parser_test.send :load_plan_number, 'DP177967'
      expect(parser_test.parcels).to include(plan_number: 'DP177967')
      expect(parser_test.parcels.size).to eq 1
    end
  end

  describe "#add_lot_number" do
    context "with empty lot lines" do
      it "won't add any value to parcels" do
        parser_test.send :add_lot_number, ''
        expect(parser_test.parcels.size).to eq 0
      end

    end
    context "with lot line" do
      it "addes lot_number to the existing plan number in @parcels" do
        parser_test.instance_eval{ @parcels = [{:plan_number=> 'DP177967'}] }
        parser_test.send :add_lot_number, 'Lot(s): 130'

        expect(parser_test.parcels[0][:lot_ids]).to include ('130')
        expect(parser_test.parcels[0][:lot_ids].size).to eq 1
      end
      it "add an new record to the @parcels" do
        parser_test.instance_eval{ @parcels = [{:plan_number=> 'DP177967', :lot_ids => [175]}] }
        parser_test.send :add_lot_number, 'Lot(s): 130'

        expect(parser_test.parcels[1][:lot_ids]).to include ('130')
        expect(parser_test.parcels.size).to eq 2
      end
    end

    context "with lot and section line" do
      it "addes lot_and section number to the existing plan number in @parcels" do
        parser_test.instance_eval{ @parcels = [{:plan_number=> 'DP177967'}] }
        parser_test.send :add_lot_number, 'Lot(s): 28, 30 Section : 2'

        expect(parser_test.parcels[0][:lot_ids]).to include ('28')
        expect(parser_test.parcels[0][:section_ids]).to include ('2')
        expect(parser_test.parcels[0][:lot_ids].size).to eq 2
      end
    end

  end

  describe "#load_lots" do
    context "with single lot line provided" do
      it "returns the original index" do
        parser_test.instance_eval{ @parcels = [{:plan_number=> 'DP177967'}] }
        result = parser_test.send :load_lots, 'Lot(s): 28, 30 Section : 2', ['DP177967', 'Lot(s): 28, 30 Section : 2'], 1
        expect(result).to eq 1
      end
    end

    context "with multiple lot lines provided" do
      it "returns the last index of the lot line" do
        parser_test.instance_eval{ @parcels = [{:plan_number=> 'DP177967'}] }
        result = parser_test.send :load_lots, 'Lot(s): 28,', ['DP177967', 'Lot(s): 28,', '29, 30,', '31,35', 'another line'], 1
        expect(result).to eq 3
      end
    end
  end

  describe "#load_polygon_type" do
    it "addes polygon type to @polygons" do
      parser_test.send :load_polygon_type, 'Road'
      expect(parser_test.polygons).to include(polygon_type: 'Road')
      expect(parser_test.polygons.size).to eq 1
    end

  end

  describe "#add_polygon_id" do
    context "with empty polygon lines" do
      it "won't add any value to @polygons" do
        parser_test.send :add_polygon_id, ''
        expect(parser_test.polygons.size).to eq 0
      end

    end
    context "with polygon id line" do
      it "addes polygon id to the existing polygon type in @polygons" do
        parser_test.instance_eval{ @polygons = [{:polygon_type=> 'Unidentified'}] }
        parser_test.send :add_polygon_id, 'Polygon Id(s): 171799814'

        expect(parser_test.polygons[0][:polygon_ids]).to include ('171799814')
        expect(parser_test.polygons[0][:polygon_ids].size).to eq 1
      end

      it "add an new record to the @polygons" do
        parser_test.instance_eval{ @polygons = [{:polygon_type=> 'Unidentified', :polygon_ids => ['171799813']}] }
        parser_test.send :add_polygon_id, 'Polygon Id(s): 171799814'

        expect(parser_test.polygons[1][:polygon_ids]).to include ('171799814')
        expect(parser_test.polygons.size).to eq 2
      end
    end
  end

  describe "#load_polygon_ids" do
    context "with single polygon id line provided" do
      it "returns the original index" do
        parser_test.instance_eval{ @polygons = [{:polygon_type=> 'Unidentified'}] }
        result = parser_test.send :load_polygon_ids, 'Polygon Id(s): 171799814', ['', 'Unidentified'], 1
        expect(result).to eq 1
      end
    end

    context "with multiple polygon id lines provided" do
      it "returns the last index of the polygon id line" do
        parser_test.instance_eval{ @polygons = [{:polygon_type=> 'Unidentified'}] }
        result = parser_test.send :load_polygon_ids, 'Polygon Id(s): 171799814,', ['', 'Polygon Id(s): 171799814,', '108018133,', '104360483', 'another line'], 1
        expect(result).to eq 3
      end
    end
  end

  describe "#find_or_create_linkage" do
    context "with existing record in the existing linkages" do
      it "returns the index of the existing record" do
        parser_test.instance_eval{ @linkages = [{:linked_plan_number=>'DP177967', :status=>"HISTORICAL", :surv_comp=>"SURVEY", :purpose=>"UNRESEARCHED"}] }
        result = parser_test.send :find_or_create_linkage, 'DP177967              HISTORICAL            SURVEY                UNRESEARCHED'
        expect(parser_test.linkages.size).to eq 1
        expect(result).to eq 0

      end
    end
    context "without record in the existing linkages" do
      it "creates an new record in the @linkages" do
        result = parser_test.send :find_or_create_linkage, 'DP177967              HISTORICAL            SURVEY                UNRESEARCHED'
        expect(parser_test.linkages.size).to eq 1
        expect(result).to eq 0
      end
    end
  end

  describe "#create_connection_between_linkage_with_parcel" do
    context "with empty @parcels or @linkages" do
      it "does nothing" do
        parser_test.send :create_connection_between_linkage_with_parcel, 0
        expect(parser_test.linkages.size).to eq 0
        expect(parser_test.parcels.size).to eq 0
      end
    end

    context "@parcels and @linkages are not empty" do
      it "just inserts the parcel's index into the @linkages and also add index to the @parcels" do
        parser_test.instance_eval{ @parcels = [{:plan_number=> 'DP177967',:lot_ids=>["1"]}]; @linkages = [{:linked_plan_number=>'DP177967', :status=>"HISTORICAL", :surv_comp=>"SURVEY", :purpose=>"UNRESEARCHED"}] }
        parser_test.send :create_connection_between_linkage_with_parcel, 0
        expect(parser_test.linkages[0][:parcel_indexes]).to include(0)
        expect(parser_test.parcels[0][:linkage_indexes]).to include(0)

      end
    end
  end

  describe "#create_connection_between_linkage_with_polygon" do
    context "with empty @polygons or @linkages" do
      it "does nothing" do
        parser_test.send :create_connection_between_linkage_with_polygon, 0
        expect(parser_test.linkages.size).to eq 0
        expect(parser_test.polygons.size).to eq 0
      end
    end

    context "@parcels and @linkages are not empty" do
      it "just inserts the polygon's index into the @linkages and also add index to the @polygons" do
        parser_test.instance_eval{ @polygons = [{:polygon_type=>"Road", :polygon_ids=>["171799813"]}]; @linkages = [{:linked_plan_number=>"DP1056287", :status=>"REGISTERED", :surv_comp=>"COMPILATION", :purpose=>"EASEMENT"}] }
        parser_test.send :create_connection_between_linkage_with_polygon, 0
        expect(parser_test.linkages[0][:polygon_indexes]).to include(0)
        expect(parser_test.polygons[0][:linkage_indexes]).to include(0)

      end
    end
  end

  describe "#load_linkages" do
    context "with linkage line" do
      it "returns the index of the current line" do
        result = parser_test.send :load_linkages, 'NSW GAZ.                     22-02-2013                   Folio : 482', ['Polygon Id(s): 171799813', 'NSW GAZ.                     22-02-2013                   Folio : 482', 'another line'], 1
        expect(result).to eq 1
      end
    end
    context "not linkage line" do
      it "returns the index of the last line of the linkage" do
        result = parser_test.send :load_linkages, 'DP177967              HISTORICAL            SURVEY                UNRESEARCHED', ['Polygon Id(s): 171799813', 'DP177967              HISTORICAL            SURVEY                UNRESEARCHED', 'DP1047039             REGISTERED            SURVEY                SUBDIVISION', 'another line'], 1
        expect(result).to eq 2

      end
    end
  end

  describe "#find_or_create_text_notation" do
    context "with existing record in the existing text notations" do
      it "returns the index of the existing record" do
        parser_test.instance_eval{ @text_notations = [{:text=>"NSW GAZ."}] }
        result = parser_test.send :find_or_create_text_notation, 'NSW GAZ.'
        expect(parser_test.text_notations.size).to eq 1
        expect(result).to eq 0

      end
    end
    context "without record in the existing text notations" do
      it "creates an new record in the @text_notations" do
        result = parser_test.send :find_or_create_text_notation, 'NSW GAZ.'
        expect(parser_test.text_notations.size).to eq 1
        expect(result).to eq 0
      end
    end
  end

  describe "#create_connection_between_text_notation_with_parcel" do
    context "with empty @parcels or @text_notations" do
      it "does nothing" do
        parser_test.send :create_connection_between_text_notation_with_parcel, 0
        expect(parser_test.text_notations.size).to eq 0
        expect(parser_test.parcels.size).to eq 0
      end
    end

    context "@parcels and @text_notations are not empty" do
      it "just inserts the parcel's index into the @text_notations and also add index to the @parcels" do
        parser_test.instance_eval{ @parcels = [{:plan_number=> 'DP177967',:lot_ids=>["1"]}]; @text_notations = [{:text=>"NSW GAZ."}]}
        parser_test.send :create_connection_between_text_notation_with_parcel, 0
        expect(parser_test.text_notations[0][:parcel_indexes]).to include(0)
        expect(parser_test.parcels[0][:text_notation_indexes]).to include(0)

      end
    end
  end

  describe "#create_connection_between_text_notation_with_polygon" do
    context "with empty @polygons or @text_notations" do
      it "does nothing" do
        parser_test.send :create_connection_between_text_notation_with_polygon, 0
        expect(parser_test.text_notations.size).to eq 0
        expect(parser_test.polygons.size).to eq 0
      end
    end

    context "@parcels and @text_notations are not empty" do
      it "just inserts the polygon's index into the @text_notations and also add index to the @polygons" do
        parser_test.instance_eval{ @polygons = [{:polygon_type=>"Road", :polygon_ids=>["171799813"]}]; @text_notations = [{:text=>"NSW GAZ."}] }
        parser_test.send :create_connection_between_text_notation_with_polygon, 0
        expect(parser_test.text_notations[0][:polygon_indexes]).to include(0)
        expect(parser_test.polygons[0][:text_notation_indexes]).to include(0)

      end
    end
  end

  describe "#load_text_notations" do
    context "with text notations line" do
      it "returns the index of the current line" do
        result = parser_test.send :load_text_notations, 'DP177967              HISTORICAL            SURVEY                UNRESEARCHED', ['Polygon Id(s): 171799813', 'DP177967              HISTORICAL            SURVEY                UNRESEARCHED', 'another line'], 1
        expect(result).to eq 1
      end
    end
    context "not linkage line" do
      it "returns the index of the last line of the linkage" do
        result = parser_test.send :load_text_notations, 'NSW GAZ.', ['Polygon Id(s): 171799813', 'NSW GAZ.','ACQUIRED','EASEMENT', 'Lot(s): 130, 131, 132'], 1
        expect(result).to eq 3

      end
    end
  end

  #will use real files to test all kinds of cases and will check the 4 data structures for the result
 describe "#run" do
   context "with parcel and linkage lines" do
     it "loads the data to the @parcels and @linkages" do
       parser = LinkageParser.new('./spec/input/parcel_linkage.txt')
       parser.run
       expect(parser.parcels.size).to eq 18
       expect(parser.linkages.size).to eq 16

       #test connection
       expect(parser.parcels[0][:linkage_indexes]).to include 0
       expect(parser.linkages[0][:parcel_indexes]).to eq [0, 1, 3]

       #test the value randomly
       expect(parser.parcels[8][:plan_number]).to eq 'DP1014491'
       expect(parser.parcels[8][:lot_ids]).to eq ['21','22']

       expect(parser.linkages[2][:linked_plan_number]).to eq 'DP1004944'
       expect(parser.linkages[2][:status]).to eq 'REGISTERED'
     end
   end
   context "with parcel and section lines" do
     it "set the section number in @parcels" do
       parser = LinkageParser.new('./spec/input/parcel_with_section.txt')
       parser.run
       expect(parser.parcels[0][:section_ids]).to include '2'
     end

   end
   context "with sp single line only(no lot line)" do
      it "doesn't get the lot value" do
        parser = LinkageParser.new('./spec/input/sp_without_lot.txt')
        parser.run
        expect(parser.parcels[6][:lot_ids]).to be_nil
        expect(parser.parcels[7][:lot_ids]).to be_nil
      end
   end
   context "with multiple lot lines" do
     it "gets all the lot numbers" do
       parser = LinkageParser.new('./spec/input/multiple_lot_lines.txt')
       parser.run
       expect(parser.parcels[6][:lot_ids].size).to eq 67

     end
   end
   context "with 'IN' in text_notation" do
     it "stores the next line too if there's 'IN' in the previous line." do
       parser = LinkageParser.new('./spec/input/multiple_lot_lines.txt')
       parser.run
       expect(parser.text_notations[0][:text]).to include 'DP1120372'
     end
   end
   context "with parcel and text notation lines" do
    it "stores the data into the parcels and text_notations" do
      parser = LinkageParser.new('./spec/input/parcel_text_notation.txt')
      parser.run

      # puts parser.text_notations
      expect(parser.parcels.size).to eq 11
      expect(parser.text_notations.size).to eq 3

      expect(parser.parcels[2][:plan_number]).to eq 'DP412362'
      expect(parser.parcels[2][:lot_ids]).to include 'Y'

      expect(parser.text_notations[0][:text]).to include 'PLAN IS FOR MINERALS ONLY'
    end
   end
   context "with polygon and linkage lines" do
     it "stores the data into polygons and linkages" do
       parser = LinkageParser.new('./spec/input/polygon_linkage.txt')
       parser.run

       expect(parser.polygons.size).to eq 1
       expect(parser.linkages.size).to eq 13

       # puts parser.polygons
       # puts parser.linkages

       expect(parser.polygons[0][:linkage_indexes]).to eq [3,4,5,6,7,8,9,10,11,12]
       expect(parser.linkages[4][:polygon_indexes]).to eq [0]

     end

   end
   context "with polygon and text notation lines" do
    it "stores the data into polygons and text_notations" do
      parser = LinkageParser.new('./spec/input/polygon_text_notation.txt')
      parser.run

      expect(parser.polygons.size).to eq 2
      expect(parser.text_notations.size).to eq 2

      expect(parser.polygons[0][:text_notation_indexes]).to include 0
      expect(parser.polygons[1][:text_notation_indexes]).to include 1

      expect(parser.text_notations[0][:polygon_indexes]).to include 0
      expect(parser.text_notations[1][:polygon_indexes]).to include 1


    end
   end
   context "with 2 pages" do
     it "combines the 2 pages and stores the data into the data structures" do
       parser = LinkageParser.new('./spec/input/2_page.txt')
       parser.run

       puts parser.text_notations
       expect(parser.parcels.size).to eq 6
       expect(parser.polygons.size).to eq 1

       expect(parser.linkages.size).to eq 9
       expect(parser.text_notations.size).to eq 6

       expect(parser.polygons[0][:linkage_indexes]).to eq [4,5,6,7,8]
       expect(parser.polygons[0][:text_notation_indexes]).to eq [5]

       expect(parser.linkages[8][:polygon_indexes]).to eq [0]
       expect(parser.text_notations[5][:polygon_indexes]).to eq [0]


     end

   end
   context "with 3 pages" do
     it "combines the 2 pages and stores the data into the data structures" do
       parser = LinkageParser.new('./spec/input/3_page.txt')
       parser.run

       # puts parser.text_notations
       expect(parser.parcels.size).to eq 8
       expect(parser.polygons.size).to eq 0

       expect(parser.linkages.size).to eq 21
       expect(parser.text_notations.size).to eq 1

       expect(parser.parcels[7][:linkage_indexes]).to eq [12,13,14,15,16,17,18,19,20]
       expect(parser.linkages[16][:parcel_indexes]).to eq [7]
     end
   end


 end

  describe "#get_indexes_from_file" do
    context "without satisfied page" do

      it "puts the message that it's not a standard txt" do
        parser = LinkageParser.new('./spec/input/invalid_file.txt')

        expect{ parser.send :get_indexes_from_file, ['aab', 'ccc'] }.to output("it's not a standard txt, please check the file - #<File:./spec/input/invalid_file.txt>\n").to_stdout

      end
    end
  end


























































































































































































end