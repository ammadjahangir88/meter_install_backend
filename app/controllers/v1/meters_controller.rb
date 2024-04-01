class V1::MetersController < ApplicationController
    before_action :set_meter, only: [:show, :update, :destroy]
  
    # GET /v1/meters
    def index
      @meters = Meter.all
      render json: @meters, status: :ok
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
  
      # Only allow a trusted parameter "white list" through.
      def meter_params
        params.require(:meter).permit(:meter_no, :reference_no, :status, :old_meter_no, :old_meter_reading, :new_meter_reading, :connection_type, :bill_month, :longitude, :latitude, :meter_type, :kwh_mf, :sanction_load, :full_name, :address, :qc_check, :pictures_upload, :subdivision_id)
      end
  end
  