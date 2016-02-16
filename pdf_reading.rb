class LinkageParser
  attr_reader :file, :linkage_lines
  #data structures
  # attr_reader :linkages #array of plans and lots ex. ['DP1044465' => [ {lot: '61', plan: 'DP758012 HISTORICAL                     COMPILATION           CROWN ADMIN NO.'}]
  attr_reader :header_lines, :footer_lines
  # attr_reader :current_plans
  # attr_accessor :current_plans_and_lots
  attr_reader :parcels, :polygons, :linkages, :text_notations
  #parcels: [{ plan_number: string, lot_ids: array, section_id: integer, linkages: [linkages_indexes], text_notations: [text_notations_indexes]}, {}, {}...]

  #polygons: [{polygon_type: type, polygon_id: string, linkages: [linkages_indexes], text_notation: [text_notations_indexes]}, {}, {}]

  #linkages: [{linked_plan_number: string, status: string, surv_comp: string, purpose: string, parcels: [parcels_indexes], polygons: [polygons_indexes]}, {}, {}..]
  #text_notations: [{text: string, parcels: [parcels_indexes], polygons: [polygons_indexes]}, {}, {}...]




  LINE_MODE = ["PLAN", "HEADER", "FOOTER", "LINKAGE", 'LOT']

  def run
    lines = @file.readlines
    parcel_blocks = lines.each_with_index.map{|line, index| index if is_parcel_header?(line.strip)}
    polygons_blocks = lines.each_with_index.map{|line, index| index-1 if is_polygon_header?(line.strip)}

    lines.each do |line|
      sline = line.strip
      is_parcel_header?(line)
      if is_polygon_header?
        @p

    end
  end

  def initialize(filename)
    begin
      @file = File.new(filename, 'r')
      @header_lines = []
      @footer_lines = []

      @parcels = @polygons = @linkages = @text_notations = []
      @current_parcel #lot_section_plan
      @parcel_begin = false
      @parcel_block = []

    rescue => e
      puts "Could not load file - #{e.message}"
    end
  end

  private
    def is_parcel_header?(line)
      line.split(' ').size == 1 && (sline.start_with?('DP') || sline.start_with?('SP'))
    end

    def is_polygon_header?(line)
      line.include?("Polygon Id(s):")
    end


  def current_plan_line?(line)
    sline = line.strip
    sline.split(' ').size == 1
  end

  def lot_line?(line)
    line.include?("Lot(s)") # get lots for current plan
  end

  # add the plan to the @current_plans_and_lots array
  # return: mode
  def get_current_plan(line, mode)
    sline = line.strip
    return mode if sline.empty?
    if sline.split(' ').size == 1
      @current_plan = {plan: sline, linkages: []} # define a new current plan  - with defaults
      # add current plan on to the main data structure
      @current_plans << sline
      @current_plans_and_lots << @current_plan
    end
    mode = 'LOT'
  end

  # add linkage to current plan or description to plan
  # return mode
  def get_linkage_detail_line(line, mode)
    sline = line.strip
    return 'FOOTER' if sline.empty? # empty line after a linkage indicates next part should the footer
    if line.split(' ').first.strip.start_with?('SP') || line.split(' ').first.strip.start_with?('DP') # is a linkage plan
      linked_plan, status, surv_comp, *purpose = line.split(' ')
      # return if linked_plan.nil? || status.nil? || surv_comp.nil? ||purpose.nil?
      @current_plans_and_lots.last[:linkages].last[:plans] << {plan_number: linked_plan.strip, status: status.strip, surv_comp: surv_comp.strip, purpose: purpose.map(&:strip).join(' ')}
    else
      @current_plans_and_lots.last[:linkages].last[:info] << line.strip
    end
    mode = 'LINKAGE'
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

  def linkages_detail_line?(line)
    line.split(' ').first.strip.start_with?('SP') || line.split(' ').first.strip.start_with?('DP')
  end

  def is_header?(line)
    line.include?("Status") && line.include?("Surv/Comp") && line.include?("Purpose")
  end



  def is_parcel_lot_or_section_number?(line)
    line.include?("Lot(s)") || line.include?("Section")
  end

  def find_or_add_parcel_plan_number(plan_number)
    @parcels.each do |parcel|
      return if parcel[:plan_number] == plan_number
    end
    @parcels << { plan_number: plan_number}
  end

  def add_lot_section_number(line)
    #find the plan number first
    @parcels.each do |parcel|

    end

    end

  def parcel_parser(lines)
    lines.each do |line|
      if is_parcel_header?(line)
        plan_number = line
        #find or add parcel plan number
        find_or_add_parcel_plan_number(plan_number)
      end
      if is_parcel_lot_or_section_number?(line)

      end
  end


  # Read each line
  def parse_line(line)
    @header_lines << line and return if is_header?(line)
    if is_parcel?(line)
      load_parcel(line)

        end
      when 'PLAN'
        return mode = get_current_plan(line, mode)
      when 'LOT'
        return mode = get_lots_for_current_plan(line, mode)
      when 'LINKAGE'
        # might be another lot based on the plan
        if lot_line?(line)
          mode = 'LOT'
          return mode = get_lots_for_current_plan(line, mode)
        elsif current_plan_line?(line) # must see if line is now a plan or end of plan section
          return mode = get_current_plan(line, mode)
        else
          return mode = get_linkage_detail_line(line, mode)
        end
      when 'FOOTER'
        sline = line.strip
        @footer_lines << line unless sline.eql?('\n')
        return mode
    end
    return mode
  end
end