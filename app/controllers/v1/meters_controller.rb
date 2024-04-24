class V1::MetersController < ApplicationController
  before_action :set_meter, only: [:show, :update, :destroy]
  require 'csv'

  # Dashboard analytics data
  def dashboard
    meters_with_divisions = Meter.joins(subdivision: :division)
    division_data = meters_with_divisions.group('divisions.id').count
    status_data = Meter.group(:METER_STATUS).count
    
    # Mapping data for frontend pie charts
    division_pie_data = division_data.map { |id, count| { name: Division.find(id).name, value: count } }
    status_pie_data = status_data.map { |status, count| { name: status, value: count } }
  
    render json: {
      divisionData: division_pie_data,
      statusData: status_pie_data
    }, status: :ok
  end

  # GET /v1/meters
  def index
    @meters = Meter.all
    render json: @meters, status: :ok
  end

  def meters_by_division
    division_id = params[:division_id]
    @meters = Meter.includes(:subdivision).where(subdivisions: { division_id: division_id })
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

  # POST /v1/meters
  def create
    @meter = Meter.new(meter_params)

    if @meter.save
      render json: @meter, status: :created
    else
      render json: @meter.errors, status: :unprocessable_entity
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

  private

  def set_meter
    @meter = Meter.find(params[:id])
  end

 
  def meter_params
    params.require(:meter).permit(:NEW_METER_NUMBER, :REF_NO, :METER_STATUS, :OLD_METER_NUMBER, :OLD_METER_READING, :NEW_METER_READING, :CONNECTION_TYPE, :BILL_MONTH, :LONGITUDE, :LATITUDE, :METER_TYPE, :KWH_MF, :SAN_LOAD, :CONSUMER_NAME, :CONSUMER_ADDRESS, :QC_CHECK, :APPLICATION_NO, :GREEN_METER, :TELCO, :SIM_NO, :SIGNAL_STRENGTH, :PICTURE_UPLOAD, :subdivision_id)
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
