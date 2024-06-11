class V1::MetersController < ApplicationController
  before_action :set_meter, only: [:show, :update, :destroy]
  # before_action :set_filters, only: [:generate_report]
  require 'csv'
  def search
    if params[:ref_no].present?
      meters = Meter.where(REF_NO: params[:ref_no])
    else
      meters = Meter.all
    end
  
    inspected_meters = meters.joins(:inspection).distinct
    uninspected_meters = meters.left_outer_joins(:inspection).where(inspections: { id: nil }).distinct
  
    render json: {
      inspected_meters: inspected_meters.as_json(include: :inspection),
      uninspected_meters: uninspected_meters
    }
  end
  
  def dashboard
    meters_with_subdivisions = Meter.joins(subdivision: :division)
    
    # Aggregate data by divisions
    division_data = meters_with_subdivisions.group('divisions.id').count
  
    # Aggregate data by subdivisions
    subdivision_data = meters_with_subdivisions.group('subdivisions.id').count
  
    # Fetch additional data for meters
    meters_data = Meter.select(:id, :LATITUDE, :LONGITUDE, :REF_NO, :METER_TYPE, :APPLICATION_NO).all
  
    # Prepare pie data for divisions
    division_pie_data = division_data.map do |id, count|
      division = Division.find(id)
      {
        id: division.id,
        name: division.name,
        value: count
      }
    end
  
    # Prepare pie data for subdivisions
    subdivision_pie_data = subdivision_data.map do |id, count|
      subdivision = Subdivision.find(id)
      {
        id: subdivision.id,
        name: subdivision.name,
        value: count
      }
    end
  
    status_pie_data = Meter.group(:METER_STATUS).count.map { |status, count| { name: status, value: count } }
    tariff_pie_data = Meter.group(:CONNECTION_TYPE).count.map { |tariff, count| { name: tariff, value: count } }
    telecom_pie_data = Meter.group(:TELCO).count.map { |telco, count| { name: telco, value: count } }
  
    render json: {
      divisionData: division_pie_data,
      subdivisionData: subdivision_pie_data, # Include this in your response
      statusData: status_pie_data,
      tariffData: tariff_pie_data,
      telecomData: telecom_pie_data,
      metersData: meters_data
    }, status: :ok
  end
  
  

  # GET /v1/meters
  def index
    @meters = Meter.all.includes(:user)

    # Join with users correctly
    if params[:user_id].present?
      @meters = @meters.where(users: { id: params[:user_id] })
    end
    
    # Other filters...
    if params[:disco_id].present?
      @meters = @meters.joins(subdivision: { division: { region: :disco } }).where(discos: { id: params[:disco_id] })
    end

    if params[:region_id].present?
      @meters = @meters.joins(subdivision: { division: :region }).where(regions: { id: params[:region_id] })
    end

    if params[:division_id].present?
      @meters = @meters.joins(subdivision: :division).where(divisions: { id: params[:division_id] })
    end

    if params[:subdivision_id].present?
      @meters = @meters.joins(:subdivision).where(subdivisions: { id: params[:subdivision_id] })
    end

    if params[:from_date].present? && params[:to_date].present?
      from_date = Date.parse(params[:from_date])
      to_date = Date.parse(params[:to_date])
      @meters = @meters.where("meters.created_at >= ? AND meters.created_at <= ?", from_date, to_date)
    end

    render json: @meters
  end

  def meters_by_division

    division_id = params[:division_id]
    @meters = Meter.includes(:subdivision).where(subdivisions: { division_id: division_id })
    render json: @meters, status: :ok
  end
  def meters_by_subdivision
  
    subdivision_id = params[:subdivision_id]
    @meters = Meter.includes(:subdivision).where(subdivisions: { id: subdivision_id })
    render json: @meters, status: :ok
  end

  def import
    uploaded_file = params[:file]
    return render json: { error: "No file uploaded" }, status: :bad_request unless uploaded_file
  
    successes = []
    errors = []
  
    CSV.foreach(uploaded_file.path, headers: true) do |row|
      meter_params = row.to_hash.slice(*Meter.attribute_names)
     
      meter_params['subdivision_id'] =params[:meter][:subdivision_id]
      meter_params['user_id'] = @current_user.id
      
      begin
       
        meter = Meter.create!(meter_params)
        successes << { ref_no: meter_params['REF_NO'], message: "Successfully imported" }
      rescue ActiveRecord::RecordInvalid => e
       
        errors << { ref_no: meter_params['REF_NO'], error: "Validation failed: #{e.record.errors.full_messages.join(", ")}" }
      end
    end
  
    if errors.empty?
      render json: { message: "All meters imported successfully", successes: successes }, status: :ok
    else
      render json: { message: "Some meters failed to import", successes: successes, errors: errors }, status: :partial_content
    end
  end
  

  def export
    meter_ids = params[:meter_ids]
    @meters = Meter.where(id: meter_ids)
  
    csv_data = CSV.generate(headers: true) do |csv|
      csv << Meter.csv_headers
      @meters.each do |meter|
        csv << meter.csv_attributes
      end
    end
  
    send_data csv_data, filename: "filtered_meters-#{Date.today}.csv", type: 'text/csv'
  end

  # GET /v1/meters/:id
  def show
    render json: @meter, except: [:created_at, :updated_at, :subdivision_id, :user_id], status: :ok
  end

  
  # POST /v1/meters
  def create
    @meter = Meter.new(meter_params.except(:image))
    if Subdivision.exists?(meter_params[:subdivision_id])
      @meter.subdivision = Subdivision.find(meter_params[:subdivision_id])
    else
      return render json: { error: "Subdivision does not exist" }, status: :unprocessable_entity
    end
  
    if meter_params[:image].present?
      @meter.image.attach(meter_params[:image])
    end
   @meter.user=@current_user
    if @meter.save
      if @meter.image.attached?
        image_url = Rails.application.routes.url_helpers.rails_blob_url(@meter.image, only_path: true)
        @meter.update(PICTURE_UPLOAD: "http://localhost:3000" + image_url)
      end
      render json: @meter, status: :created
    else
      render json: { errors: @meter.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  

  # PATCH/PUT /v1/meters/:id
  def update
    if @meter.update(meter_params)
      render json: @meter, status: :ok
    else
      render json: @meter.errors, status: :unprocessable_entity
    end
  end

  # DELETE /v1/meters/:id
  def destroy
    @meter.destroy
    head :no_content
  end
  # app/controllers/v1/meters_controller.rb
  def bulk_delete
    meter_ids = params[:meter_ids]  # Assuming meter_ids are passed as an array
    Meter.where(id: meter_ids).destroy_all
    head :no_content  # No content to return after deletion
  rescue StandardError => e
    render json: { error: "Failed to delete meters: #{e.message}" }, status: :unprocessable_entity
  end
  def generate_report

    @user = User.find_by(id: params[:user_id])
   
    # Handling the case where no validl user is found
    if @user.nil?
      render json: { error: 'User not found' }, status: :not_found
      return
    end
    
    @meters = Meter.includes(user: {}, subdivision: { division: { region: :disco } })
    apply_filters!
    
    # Pass additional context about the hierarchical data to the service
    context_params = {
      disco_id: params[:disco_id],
      region_id: params[:region_id],
      division_id: params[:division_id],
      subdivision_id: params[:subdivision_id],
      from_date: params[:from_date],
      to_date: params[:to_date]
    }
    
    pdf = MeterReportService.new(@meters, @user, context_params).generate_pdf
    send_data pdf, filename: "meter_report_#{Time.zone.now.to_date}.pdf", type: 'application/pdf', disposition: 'attachment'
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end
  
  private
  


  private
 
  def set_filters
    @meters = Meter.includes(:user, subdivision: { division: { region: :disco } })
    filter_by_params
  end

  def apply_filters!
    filter_by_params
    apply_date_filters
  end
  
  def filter_by_params
    
    @meters = @meters.where(user_id: params[:user_id]) if params[:user_id].present?
    @meters = @meters.joins(:subdivision).where(subdivisions: { id: params[:subdivision_id] }) if params[:subdivision_id].present?
    @meters = @meters.joins(subdivision: { division: {} }).where(divisions: { id: params[:division_id] }) if params[:division_id].present?
    @meters = @meters.joins(subdivision: { division: { region: {} } }).where(regions: { id: params[:region_id] }) if params[:region_id].present?
    @meters = @meters.joins(subdivision: { division: { region: { disco: {} } } }).where(discos: { id: params[:disco_id] }) if params[:disco_id].present?
  end
  
  def apply_date_filters
    if params[:from_date].present? && params[:to_date].present?
      from_date = Date.parse(params[:from_date])
      to_date = Date.parse(params[:to_date])
      @meters = @meters.where("meters.created_at >= ? AND meters.created_at <= ?", from_date, to_date)
    end
  
  end
  

  
  def set_meter
    @meter = Meter.find(params[:id])
  end
  def format_errors(errors)
    errors.to_hash(true).map do |field, messages|
      { field: field, errors: messages.join(', ') }
    end
  end
  def report_params
    params.permit(:user_id, :disco_id, :region_id, :division_id, :subdivision_id, :from_date, :to_date)
  end
  def meter_params
    params.require(:meter).permit(
      :NEW_METER_NUMBER, :REF_NO, :METER_STATUS, :OLD_METER_NUMBER, :OLD_METER_READING, 
      :NEW_METER_READING, :CONNECTION_TYPE, :BILL_MONTH, :LONGITUDE, :LATITUDE, :METER_TYPE, 
      :KWH_MF, :SAN_LOAD, :CONSUMER_NAME, :CONSUMER_ADDRESS, :QC_CHECK, :APPLICATION_NO, 
      :GREEN_METER, :TELCO, :SIM_NO, :SIGNAL_STRENGTH, :PICTURE_UPLOAD, :METR_REPLACE_DATE_TIME, 
      :NO_OF_RESET_OLD_METER, :NO_OF_RESET_NEW_METER, :KWH_T1, :KWH_T2, :KWH_TOTAL, 
      :KVARH_T1, :KVARH_T2, :KVARH_TOTAL, :MDI_T1, :MDI_T2, :MDI_TOTAL, 
      :CUMULATIVE_MDI_T1, :CUMULATIVE_MDI_T2, :CUMULATIVE_MDI_Total, :subdivision_id,:image
    ).tap do |sanitized_params|
      sanitized_params[:image] = nil if sanitized_params[:image] == "null"
    end
  end
  
  def authenticate_request!
    header = request.headers['Authorization']
    if header && header.split(' ').first == 'JWT'
      token = header.split(' ').last
      begin
        decoded_token = JWT.decode(token, 'your_secret_key', true, algorithm: 'HS256')
        @current_user = User.find(decoded_token.first['user_id'])
      rescue JWT::DecodeError => e
        render json: { message: 'Invalid token' }, status: :unauthorized
      end
    else
      render json: { message: 'Authorization header missing' }, status: :unauthorized
    end
  end
end
