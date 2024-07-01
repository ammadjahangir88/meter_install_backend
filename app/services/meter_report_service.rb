require 'prawn'
require 'gruff'

class MeterReportService
  def initialize(meters, user, context_params)
    @meters = meters
    @user = user
    @context_params = context_params
  end

  def generate_pdf
    return 'No meters found' if @meters.nil? || @meters.empty?

    pdf = Prawn::Document.new
    setup_pdf(pdf)
    add_pie_chart(pdf) unless @meters.empty?
    pdf.render
  end

  private

  def setup_pdf(pdf)
    pdf.text "Meter Installation Report", size: 18, style: :bold
    pdf.move_down 10
    pdf.text "Report generated on: #{Date.today}", size: 12
    pdf.text "Report by Field Supervisor: #{@user.username}"
   
    # Adding dynamic hierarchical information
    if @context_params[:disco_id] != ''
      disco = Disco.find(@context_params[:disco_id])
      pdf.text "Disco: #{disco.name}", size: 12
    end
  
    if @context_params[:region_id] != ''
      region = Region.find(@context_params[:region_id])
      pdf.text "Region: #{region.name}", size: 12
    end
  
    if @context_params[:division_id] != ''
      division = Division.find(@context_params[:division_id])
      pdf.text "Division: #{division.name}", size: 12
    end
  
    if @context_params[:subdivision_id] != ''
      subdivision = Subdivision.find(@context_params[:subdivision_id])
      pdf.text "Subdivision: #{subdivision.name}", size: 12
    end
 
    # Display the date range if available
    from_date = @context_params[:from_date]
    to_date = @context_params[:to_date]
    if from_date.present? && to_date.present?
      pdf.text "Report covers period: #{from_date} to #{to_date}", size: 12
    elsif from_date.present?
      pdf.text "Report from: #{from_date}", size: 12
    elsif to_date.present?
      pdf.text "Report up to: #{to_date}", size: 12
    end
  
    pdf.move_down 5
    pdf.text "Total Meters Installed: #{ @meters.count}"
  end
  

  def add_pie_chart(pdf)
    pie_data = @meters.group_by(&:CONNECTION_TYPE).transform_values(&:count)
    chart = Gruff::Pie.new
    pie_data.each { |type, count| chart.data(type, count) }

    chart_image = chart.to_image
    chart_blob = chart_image.to_blob
    image_stream = StringIO.new(chart_blob)
    pdf.image image_stream, scale: 0.50
  end
end
