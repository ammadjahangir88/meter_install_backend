require 'prawn'
require 'gruff'

class MeterReportService
  def initialize(meters, user)
    @meters = meters
    @user = user
  end

  def generate_pdf
    return 'No meters found' if @meters.nil? || @meters.empty?

    pdf = Prawn::Document.new
    setup_pdf(pdf)
   
    # add_meter_count_by_type(pdf)
    add_pie_chart(pdf) unless @meters.empty?
    pdf.render
  end

  private

  def setup_pdf(pdf)
    pdf.text "Meter Installation Report", size: 18, style: :bold
    pdf.move_down 10
    pdf.text "Report generated on: #{Date.today}", size: 12
    pdf.text "Report by Field Supervisor: #{@user.username}"
    pdf.move_down 5
    pdf.text "Total Meter Installed: #{ @meters.count}"
    connection_types = @meters.group_by(&:CONNECTION_TYPE)
    connection_types.each do |type, meters|
      pdf.text "#{type} Meters installed: #{meters.count}", size: 12
    end
   
  end

  def add_meter_count_by_type(pdf)
   
  
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

  # Ensure to include other necessary methods
end
