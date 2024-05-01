class V1::MetersController < ApplicationController
  before_action :set_meter, only: [:show, :update, :destroy]
  # before_action :set_filters, only: [:generate_report]
  require 'csv'

  def dashboard
    meters_with_divisions = Meter.joins(subdivision: :division)
    division_data = meters_with_divisions.group('divisions.id').count
  
    # Fetch additional data for meters
    meters_data = Meter.select(:id, :LATITUDE, :LONGITUDE, :REF_NO, :METER_TYPE, :APPLICATION_NO).all
  
    division_pie_data = division_data.map do |id, count|
      division = Division.find(id)
      {
        id: division.id,
        name: division.name,
        value: count
      }
    end
  
    status_pie_data = Meter.group(:METER_STATUS).count.map { |status, count| { name: status, value: count } }
    tariff_pie_data = Meter.group(:CONNECTION_TYPE).count.map { |tariff, count| { name: tariff, value: count } }
    telecom_pie_data = Meter.group(:TELCO).count.map { |telco, count| { name: telco, value: count } }
  
    render json: {
      divisionData: division_pie_data,
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
  
    begin
      CSV.foreach(uploaded_file.path, headers: true) do |row|
        meter_params = row.to_hash.slice(*Meter.attribute_names)
        meter_params['subdivision_id'] = 1
        Meter.create!(meter_params)
      end
      render json: { message: "Meters imported successfully" }, status: :ok
    rescue ActiveRecord::RecordInvalid => e
      # This captures any validation errors from the model on save.
      render json: { error: "Validation failed: #{e.message}" }, status: :unprocessable_entity
    rescue StandardError => e
      # This captures any other errors that could occur, such as issues with the CSV formatting.
      render json: { error: "Import failed: #{e.message}" }, status: :unprocessable_entity
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
    render json: @meter, status: :ok
  end
  def generate_report
    @meters = Meter.includes(:user, subdivision: { division: { region: :disco } })
    apply_filters!
    pdf = MeterReportService.new(@meters).generate_pdf
    send_data pdf, filename: "meter_report_#{Time.zone.now.to_date}.pdf", type: 'application/pdf', disposition: 'attachment'
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end
  
  # POST /v1/meters
  def create
    # binding.pry
    @meter = Meter.new(meter_params)
    subdivision=Subdivision.first
    @meter.subdivision=subdivision
    @meter.save
    @meter.PICTURE_UPLOAD = "http://localhost:3000"+Rails.application.routes.url_helpers.rails_representation_url(@meter.image, only_path: true)

    if @meter.save

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
    # Assuming 'user_id' is passed as a parameter and it is valid.
    @user = User.find_by(id: params[:user_id])
    
    # Handling the case where no valid user is found
    if @user.nil?
      render json: { error: 'User not found' }, status: :not_found
      return
    end
  
    @meters = Meter.includes(user: {}, subdivision: { division: { region: :disco } })
    apply_filters!
  
    # Pass the user to the service
    pdf = MeterReportService.new(@meters, @user).generate_pdf
    send_data pdf, filename: "meter_report_#{Time.zone.now.to_date}.pdf", type: 'application/pdf', disposition: 'attachment'
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end
  
  private
  
  def apply_filters!
    @meters = @meters.where(user_id: params[:user_id]) if params[:user_id].present?
    @meters = @meters.where(subdivisions: { id: params[:subdivision_id] }) if params[:subdivision_id].present?
    @meters = @meters.where(divisions: { id: params[:division_id] }) if params[:division_id].present?
    @meters = @meters.where(regions: { id: params[:region_id] }) if params[:region_id].present?
    @meters = @meters.where(discos: { id: params[:disco_id] }) if params[:disco_id].present?
    apply_date_filters if params[:from_date].present? && params[:to_date].present?
  end


  private
 
  def set_filters
    @meters = Meter.includes(:user, subdivision: { division: { region: :disco } })
    filter_by_params
  end

  def filter_by_params
    @meters = @meters.where(user_id: params[:user_id]) if params[:user_id].present?
    @meters = @meters.where(subdivisions: { id: params[:subdivision_id] }) if params[:subdivision_id].present?
    @meters = @meters.where(divisions: { id: params[:division_id] }) if params[:division_id].present?
    @meters = @meters.where(regions: { id: params[:region_id] }) if params[:region_id].present?
    @meters = @meters.where(discos: { id: params[:disco_id] }) if params[:disco_id].present?
    apply_date_filters if params[:from_date].present? && params[:to_date].present?
  end

  def apply_date_filters
    from_date = Date.parse(params[:from_date])
    to_date = Date.parse(params[:to_date])
    @meters = @meters.where("bill_month >= ? AND bill_month <= ?", from_date, to_date)
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
    )
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
