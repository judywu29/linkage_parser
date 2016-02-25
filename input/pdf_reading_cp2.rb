
class LinkageParser
  attr_reader :file, :linkage_lines
  #data structures
  # attr_reader :linkages #array of plans and lots ex. ['DP1044465' => [ {lot: '61', plan: 'DP758012 HISTORICAL                     COMPILATION           CROWN ADMIN NO.'}]
  attr_reader :header_lines, :footer_lines
  # attr_reader :current_plans
  # attr_accessor :current_plans_and_lots
  attr_reader :parcels, :polygons, :linkages, :text_notations
  #parcels: [{ plan_number: string, lot_ids: array, section_id: integer, linkages: [linkages_indexes], text_notations: [text_notations_indexes]}, {}, {}...]

  #polygons: [{polygon_type: string, polygon_id: string, linkages: [linkages_indexes], text_notation: [text_notations_indexes]}, {}, {}]

  #linkages: [{linked_plan_number: string, status: string, surv_comp: string, purpose: string, parcels: [parcels_indexes], polygons: [polygons_indexes]}, {}, {}..]
  #text_notations: [{text: string, parcels: [parcels_indexes], polygons: [polygons_indexes]}, {}, {}...]

  #
  #
  #
  # LINE_MODE = ["PLAN", "HEADER", "FOOTER", "LINKAGE", 'LOT']
  POLYGON_TYPES = ['Road', 'Water','Unidentified', 'Intersection']

  def run
    # raw_lines = @file.readlines
    lines = @file.readlines
    # puts raw_lines
    # encoding_lines = raw_lines.join("@@@").force_encoding("ISO-8859-1").encode("utf-8", replace: nil)
    # lines = encoding_lines.split("@@@")
    start_index = lines.index{|line| line.include?("Status") && line.include?("Surv/Comp") && line.include?("Purpose")} + 1
    end_index = lines.index{|line| line.include?("Page") && line.include?("of") }
    while start_index < end_index do
      start_index = load_parcel(lines, start_index)
      start_index = load_polygon(lines, start_index)
      # elsif is_polygon_type_line?(line)
      #   index = load_polygon(lines, index)

      start_index += 1

    end


    #text_notation



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
  def is_plan_number_line?(line)
    line.split(' ').size == 1 && (line.start_with?('DP') || line.start_with?('SP'))
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



  # Expecting the line to have linked plan and details or extra info
  # Set plan linkage structure with defaults
  # return mode = 'LINKAGE'
  def get_lots_for_current_plan(line, mode)
    sline = line.strip
    return mode if sline.empty? # may be empty line after lots. This would indicate leading into footer
    # {lots: [], plans: []} for current plan
    if sline.include?("Lot(s)") # get lots for current plan
      @current_plans_and_lots.last[:linkages] << {lots: sline.split("Lot(s):")[1].strip, polyeogons: [], plans: [], info: []}
    end
    if sline.include?("Polygon Id(s):") # get polygons for current Road plan
      @current_plans_and_lots.last[:linkages] << {lots: [], polygons: sline.split("Polygon Id(s):")[1].split(",").map(&:strip), plans: [], info: []}
    end
    # might not have lots

    return mode if sline.include?('all ACTIVITY PRIOR to SEPT 2002')
    return mode if sline.include?('Report Generated')
    return mode if sline.include?('Land and Property')
    # if !sline.include?("Lot(s)") && !sline.include?("Polygon Id(s):") || !sline.strip.start_with?("NSW GAZ") #linkages_detail_line?(line) ||

    if !sline.include?("Lot(s)") && !sline.include?("Polygon Id(s):") #linkages_detail_line?(line) || line.strip.start_with?("NSW GAZ")
      @current_plans_and_lots.last[:linkages] << {lots: [], polygons: [], plans: [], info: []}
      get_linkage_detail_line(line, mode)
    end
    mode = 'LINKAGE'
  end

  def is_linkages_detail_line?(line)
    arr_line = line.split(' ')
    arr_line.length > 1 && (arr_line[0].strip.start_with?('SP') || arr_line[0].strip.start_with?('DP'))
  end

  def is_text_notation_line?(line)
    arr_line = line.split(' ')
    arr_line.length > 1 && (arr_line[0].strip.start_with?('SP') || arr_line[0].strip.start_with?('DP'))
  end

  # def is_header?(line)
  #   line.include?("Status") && line.include?("Surv/Comp") && line.include?("Purpose")
  # end


  def load_parcel(lines, start_index)
    plan_lot_start = false

    if is_plan_number_line?(line = lines[start_index])
      plan_number = line.strip

      line = lines[start_index += 1] #next line
      plan_lot_start = true
    end

    if is_parcel_lot_or_section_line?(line)
      lot_lines = line.strip
      while is_lot_number_continue?(lot_lines) do #check the next time is still lot line
        lot_lines += lines[start_index += 1].strip
      end

      line = lines[start_index += 1]
      plan_lot_start = true
    end

    # puts "plan_number = #{plan_number} and lot_number = #{lot_lines}"
    return start_index unless plan_lot_start

    add_parcel(lot_lines, plan_number)
    #linkage_lines
    while is_linkages_detail_line?(line) do
      add_linkage_to_parcels(line)
      line = lines[start_index += 1].strip
    end

    return start_index-1
end

  def is_parcel_lot_or_section_line?(line)
    line.include?("Lot(s)") || line.include?("Section")
  end

  def is_lot_number_continue?(line)
    puts "line: #{line}"
    line.end_with?(",")
  end

  def add_parcel(lot_lines, plan_number)
    plan_number = @parcels[-1][:plan_number] if plan_number.nil?
    @parcels << { plan_number: plan_number}
    unless lot_lines.nil?
      lines = lot_lines.split("Lot(s):")[1].split("Section :")
      if lines.length > 1
        section_lines = lines[1].split(",").map(&:strip)
        @parcels[-1][:section_id] = section_lines
      end
      @parcels[-1][:lot_ids] = lines[0].split(",").map(&:strip)
    end
  end


  def add_linkage_to_parcels(linkage_line)

    parcel_linkages = @parcels[-1][:linkage_indexes] ||= []
    # puts "@parcels: #{@parcels[-1]}"
    linked_plan, status, surv_comp, *purpose = linkage_line.split(' ')
    parcel_index = @parcels.length-1
    @linkages.each_with_index do |linkage, index|
      if linkage[:linked_plan_number] == linked_plan
        linkage[:polygon_indexes] ||= []
        linkage[:parcel_indexes] << parcel_index
        #add to @parcels:
        parcel_linkages << index
        return
      end
    end
    @linkages << {linked_plan_number: linked_plan, status: status, surv_comp: surv_comp, purpose: purpose.join(" "), parcel_indexes: [parcel_index] }
    parcel_linkages << @linkages.length-1

  end

  def load_polygon(lines, start_index)
    polygon_start = false
    # puts "Line: #{lines[start_index]}"
    if is_polygon_type_line?(line = lines[start_index])
      polygon_type = line.strip
      line = lines[start_index += 1] #next line
      polygon_start = true
    end

    if is_polygon_id_line?(line)
      polygon_ids_lines = line.strip
      while is_polygon_id_continue?(polygon_ids_lines) do #check the next time is still lot line
        lot_lines += lines[start_index += 1].strip
      end
      polygon_start = true
      line = lines[start_index += 1]
    end

    # puts "plan_number = #{plan_number} and lot_number = #{lot_lines}"
    return start_index unless polygon_start

    add_polygon(polygon_ids_lines, polygon_type)
    #linkage_lines
    while is_linkages_detail_line?(line) do
      add_linkage_to_polygons(line)
      line = lines[start_index += 1].strip
    end

    return start_index-1
  end

  def is_polygon_id_continue?(line)
    line[-1] == ","
  end

  def add_polygon(polygon_ids_lines, polygon_type)
    @polygons << { polygon_type: polygon_type, polygon_id: polygon_ids_lines.split("Polygon Id(s):")[1].split(",").map(&:strip) }
  end

  def add_linkage_to_polygons(linkage_line)
    polygon_linkages = @polygons[-1][:linkage_indexes] ||= []
    # puts "@parcels: #{@parcels[-1]}"
    linked_plan, status, surv_comp, *purpose = linkage_line.split(' ')
    polygon_index = @polygons.length-1
    @linkages.each_with_index do |linkage, index|
      if linkage[:linked_plan_number] == linked_plan
        linkage[:polygon_indexes] ||= []
        linkage[:polygon_indexes] << polygon_index
        #add to @parcels:
        polygon_linkages << index
        return
      end
    end
    @linkages << {linked_plan_number: linked_plan, status: status, surv_comp: surv_comp, purpose: purpose.join(" "), polygon_indexes: [polygon_index] }
    polygon_linkages << @linkages.length-1

  end


  # # Read each line
  # def parse_line(line)
  #   @header_lines << line and return if is_header?(line)
  #   if is_parcel?(line)
  #     load_parcel(line)
  #
  #       end
  #     when 'PLAN'
  #       return mode = get_current_plan(line, mode)
  #     when 'LOT'
  #       return mode = get_lots_for_current_plan(line, mode)
  #     when 'LINKAGE'
  #       # might be another lot based on the plan
  #       if lot_line?(line)
  #         mode = 'LOT'
  #         return mode = get_lots_for_current_plan(line, mode)
  #       elsif current_plan_line?(line) # must see if line is now a plan or end of plan section
  #         return mode = get_current_plan(line, mode)
  #       else
  #         return mode = get_linkage_detail_line(line, mode)
  #       end
  #     when 'FOOTER'
  #       sline = line.strip
  #       @footer_lines << line unless sline.eql?('\n')
  #       return mode
  #   end
  #   return mode
  # end
end