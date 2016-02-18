
class LinkageParser
  attr_reader :file
  #data structures
  attr_reader :parcels, :polygons, :linkages, :text_notations

  POLYGON_TYPES = ['Road', 'Water','Unidentified', 'Intersection']

  def run
    lines = @file.readlines

    indexes = get_indexes_from_file(lines)
    @is_polygon = false #it's used when add connection linkages/text_notations with parcel/polygon

    #to handle multiple pages:
    (0...indexes.size).step(2).each do |i|
      start_index = indexes[i]
      while start_index && (start_index < indexes[i+1])
        line = lines[start_index].strip

        case
          when is_plan_number_line?(line)
            @is_polygon = false
            load_plan_number(line)
          when is_lot_or_section_line?(line)
            start_index = load_lots(line, lines, start_index)
          when is_polygon_type_line?(line)
            @is_polygon = true
            load_polygon_type(line)
          when is_polygon_id_line?(line)
            start_index = load_polygon_ids(line, lines, start_index)
          else
            #linkage:
            start_index = load_linkages(line, lines, start_index, @is_polygon)
            #text notation
            start_index = load_text_notations(line, lines, start_index, @is_polygon)
        end
        start_index += 1
      end
    end
  end


  def initialize(filename)
    begin
      @file = File.new(filename, 'rb')

      @parcels = []
      @polygons = []
      @linkages = []
      @text_notations = []

    rescue => e
      puts "Could not load file - #{e.message}"
    end
  end

  private

  def get_indexes_from_file(lines)
    #assumptions made here: the size of indexes have to be even and there should be header in each page, 'Caution'
    # at the end of the first page and 'blah' at the pages except the first page if there are multiple pages
    start_indexes = []
    lines.each_with_index{|line, index| start_indexes << (index + 1) if line.include?("Surv/Comp") && line.include?("Purpose")}

    caution_index = lines.index{|line| line.include?("Caution") }

    indexes = start_indexes << caution_index
    lines.each_with_index{|line, index| indexes << index if line.include?("blah") }


    indexes.keep_if{ |i| i && i > 0 }.sort! #remove the nil value and only keep the positive values, sort the array 
    # puts indexes

    if start_indexes.empty? || caution_index == -1 || indexes.size % 2 != 0
      puts "it's not a standard txt, please check the file - #{@file.inspect}"
    end
    return indexes
  end

  def is_plan_number_line?(line)
    line.split(' ').size == 1 && (line.start_with?('DP') || line.start_with?('SP'))
  end

  def is_lot_or_section_line?(line)
    line.include?("Lot(s)") || line.include?("Section")
  end

  def is_polygon_id_line?(line)
    line.include?("Polygon Id(s):")
  end

  def is_polygon_type_line?(line)
    POLYGON_TYPES.each do |type|
      return true if line.start_with?(type)
    end
    return false
  end

  def is_linkages_detail_line?(line)
    arr_line = line.split(' ')
    arr_line.length > 1 && (arr_line[0].strip.start_with?('SP') || arr_line[0].strip.start_with?('DP'))
  end

  def is_empty_line?(line)
    line.nil? || line == "" || line.eql?("\n")
  end

  def is_text_notation_line?(line)
    !(is_plan_number_line?(line) || is_lot_or_section_line?(line) || is_polygon_id_line?(line) || is_polygon_type_line?(line) || is_linkages_detail_line?(line) || is_empty_line?(line))
  end

  def is_continued?(line)
    line.end_with?(",")
  end

  def load_plan_number(plan_number)
    @parcels << { plan_number: plan_number}
  end

  #store the value(lot or and section number) to the @parcels, if the last record already has the key,
  # #then create an new hash with plan number and insert into the @parcels
  def add_lot_number(lot_lines)
    unless lot_lines.nil? || lot_lines.empty? || @parcels.empty?
      hash_parcel = {}
      lines = lot_lines.split("Lot(s):")[1].split("Section :")
      if lines.length > 1
        section_lines = lines[1].split(",").map(&:strip)
        hash_parcel.merge!({ section_ids: section_lines })
      end
      hash_parcel.merge!({ lot_ids: lines[0].split(",").map(&:strip) })

      parcel = @parcels[-1]
      if parcel[:lot_ids]
        hash_parcel.merge!({ plan_number: @parcels[-1][:plan_number] })
        @parcels << hash_parcel
      else
        @parcels[-1].merge!(hash_parcel)
      end
    end
  end

  #there would be multiple lot lines, will check the the next line if it's also lot line(the current line ends with comma)
  def load_lots(current_line, lines, start_index)
    lot_lines = current_line
    while is_continued?(lot_lines) do #check the next time is still lot line
      lot_lines += lines[start_index += 1].strip
    end
    add_lot_number(lot_lines)
    start_index
  end

  def load_polygon_type(type)
    @polygons << { polygon_type: type}
  end

  #similar way as lot number
  def add_polygon_id(ids)
    unless ids.nil? || ids.empty? || @polygons.empty?
      hash_polygon = {}
      lines = ids.split("Polygon Id(s):")[1]
      hash_polygon.merge!({ polygon_ids: lines.split(",").map(&:strip) })

      polygon = @polygons[-1]
      if polygon[:polygon_ids]
        hash_polygon.merge!({ polygon_type: @polygons[-1][:polygon_type] })
        @polygons << hash_polygon
      else
        @polygons[-1].merge!(hash_polygon)
      end
    end
  end

  #similar way as lot number
  def load_polygon_ids(current_line, lines, start_index)
    polygon_id_lines = current_line
    while is_continued?(polygon_id_lines) do #check the next time is still polygon id line
      polygon_id_lines += lines[start_index += 1].strip
    end
    add_polygon_id(polygon_id_lines)
    start_index
  end


  def load_linkages(line, lines, start_index, is_polygon = false)
    index = start_index
    while line && is_linkages_detail_line?(line) do
      linkage_index = find_or_create_linkage(line)
      is_polygon ? create_connection_between_linkage_with_polygon(linkage_index) : create_connection_between_linkage_with_parcel(linkage_index)
      line = lines[index += 1].strip
    end
    index > start_index ? (index - 1) : start_index
  end

  def find_or_create_linkage(linkage_line)
    linked_plan, status, surv_comp, *purpose = linkage_line.split(' ')
    @linkages.each_with_index do |linkage, index|
      if linkage[:linked_plan_number] == linked_plan
        return index
      end
    end
    #not found in the exisiting linkages, create new linkage and add indexes
    @linkages << {linked_plan_number: linked_plan, status: status, surv_comp: surv_comp, purpose: purpose.join(" ") }
    return @linkages.length - 1

  end

    #add indexes to each other(linkage and parcel)
  def create_connection_between_linkage_with_parcel(linkage_index)
    return if @parcels.empty? || @linkages.empty?

    #add indexes to parcels
    linkage_indexes = @parcels[-1][:linkage_indexes] ||= []
    linkage_indexes << linkage_index

    #add indexes to linkages
    parcel_indexes = @linkages[linkage_index][:parcel_indexes] ||= []
    parcel_indexes << @parcels.length-1

  end


  #similar way as parcel
  def create_connection_between_linkage_with_polygon(linkage_index)
    return if @polygons.empty? || @linkages.empty?

    #add indexes to parcels
    linkage_indexes = @polygons[-1][:linkage_indexes] ||= []
    linkage_indexes << linkage_index

    #add indexes to linkages
    polygon_indexes = @linkages[linkage_index][:polygon_indexes] ||= []
    polygon_indexes << @polygons.length-1

  end

  def load_text_notations(line, lines, start_index, is_polygon = false)
    texts = []
    while line && is_text_notation_line?(line) do
      texts << line
      line = lines[start_index += 1].strip
    end

    return start_index if texts.empty?

    #handle special case: the line ends with 'IN'
    texts << line && start_index += 1 if texts[-1].end_with?('IN')

    text_notation_index = find_or_create_text_notation(texts.join("\n"))
    is_polygon ? create_connection_between_text_notation_with_polygon(text_notation_index) : create_connection_between_text_notation_with_parcel(text_notation_index)
    return start_index - 1

  end

  #add find or create text notation in @text_notations
  def find_or_create_text_notation(text)
    @text_notations.each_with_index do |notation, index|
      if notation[:text] == text
        return index
      end
    end
    #not found, create an new record
    @text_notations << {text: text}
    return @text_notations.length - 1
  end

  #insert indexes to each other(text_notations and parcels)
  def create_connection_between_text_notation_with_parcel(text_notation_index)
    return if @parcels.empty? || @text_notations.empty?

    #add indexes to parcels
    text_notation_indexes = @parcels[-1][:text_notation_indexes] ||= []
    text_notation_indexes << text_notation_index

    #add indexes to linkages
    parcel_indexes = @text_notations[text_notation_index][:parcel_indexes] ||= []
    parcel_indexes << @parcels.length-1
  end

  #similar way as parcel(add_text_notation_to_parcel)
  def create_connection_between_text_notation_with_polygon(text_notation_index)
    return if @polygons.empty? || @text_notations.empty?

    #add indexes to parcels
    text_notation_indexes = @polygons[-1][:text_notation_indexes] ||= []
    text_notation_indexes << text_notation_index

    #add indexes to linkages
    polygon_indexes = @text_notations[text_notation_index][:polygon_indexes] ||= []
    polygon_indexes << @polygons.length-1
  end



end