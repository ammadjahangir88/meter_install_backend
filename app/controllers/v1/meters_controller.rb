class V1::MetersController < ApplicationController
    before_action :set_meter, only: [:show, :update, :destroy]
    require 'csv'
    def dashboard
      meters_with_divisions = Meter.joins(subdivision: :division)
      division_data = meters_with_divisions.group('divisions.id').count
      status_data = Meter.group(:status).count
      
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

    def import
      uploaded_file = params[:file]
      return render json: { error: "No file uploaded" }, status: :bad_request unless uploaded_file
    
      begin
        CSV.foreach(uploaded_file.path, headers: true) do |row|
          # Map CSV headers to database columns, filtering out any missing or irrelevant fields
          mapped_attributes = map_csv_to_db(row.to_hash)
          Meter.create!(mapped_attributes)
        end
        render json: { message: "Meters imported successfully" }, status: :ok
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.message }, status: :unprocessable_entity
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
    end
    
  
  
    def export
      # Assume you're sending the IDs of the meters you want to export
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

      # Use callbacks to share common setup or constraints between actions.
      def set_meter
        @meter = Meter.find(params[:id])
      end
      def map_csv_to_db(row)
        # Map from CSV header names to database column names
        mapping = {
          "Application No" => "APPLICATION_NO",
          "Reference No" => "reference_no",
          "Meter Status" => "status",
          "Green Meter" => "GREEN_METER",
          "New Meter Number" => "NEW_METER_NUMBER",
          "Old Meter Number" => "old_meter_no",
          "New Meter Reading" => "new_meter_reading",
          "Connection Type" => "connection_type",
          "San Load" => "sanction_load",
          "Bill Month" => "bill_month",
          "Meter Type" => "meter_type",
          "Kwh MF" => "kwh_mf",
          "Telco" => "TELCO",
          "SIM No" => "SIM_NO",
          "Signal Strength" => "SIGNAL_STRENGTH",
          "Consumer Name" => "full_name",
          "Address" => "address",
          "Picture Upload" => "PICTURE_UPLOAD",
          "Longitude" => "longitude",
          "Latitude" => "latitude",
          "subdivision_id" => '1',
        }
      
        mapped_row = {}
        row.each do |key, value|
          # Only map the field if it is included in the CSV and the mapping
          mapped_row[mapping[key]] = value if mapping[key] && row.has_key?(key)
        end
        mapped_row['subdivision_id'] = '1' unless mapped_row.has_key?('subdivision_id')
        mapped_row
      end
  
      # Only allow a trusted parameter "white list" through.
      def meter_params
        params.require(:meter).permit(:meter_no, :reference_no, :status, :old_meter_no, :old_meter_reading, :new_meter_reading, :connection_type, :bill_month, :longitude, :latitude, :meter_type, :kwh_mf, :sanction_load, :full_name, :address, :qc_check, :pictures_upload, :subdivision_id)
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
  