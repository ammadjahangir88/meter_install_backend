    class V1::RegionsController < ApplicationController
        before_action :set_region, only: [:show, :update, :destroy]
    
        # GET /v1/regions
        def index
           
        if params[:disco_id]
            @regions = Region.where(disco_id: params[:disco_id])
        else
            @regions = Region.all
        end
            render json: @regions
        end
    
        def show
            @region = Region.find(params[:id])
          
            divisions_data = @region.divisions.includes(:meters).map do |division|
              {
                id: division.id,
                name: division.name,
                value: division.meters.count
              }
            end
          
            # Calculate additional metrics for meters in the region
            total_meters = @region.meters.count
            meters_installed = @region.meters.where.not(user_id: nil).count
            meters_qc_done = @region.meters.joins(:inspection).count
            meters_qc_ok = @region.meters.joins(:inspection).where(inspections: { meter_type_ok: true, display_verification_ok: true, installation_location_ok: true, wiring_connection_ok: true, sealing_ok: true, documentation_ok: true, compliance_assurance_ok: true }).count
            meters_qc_remaining = @region.meters.where.not(user_id: nil).left_outer_joins(:inspection).where(inspections: { id: nil }).count
            meters_to_be_installed = total_meters - meters_installed
          
        
            render json: {
                region: @region,
                divisionsData:  divisions_data,
                totalMeters: total_meters,
                metersInstalled: meters_installed,
                metersQCDone: meters_qc_done,
                metersQCOK: meters_qc_ok,
                metersQCRemaining: meters_qc_remaining,
                metersToBeInstalled: meters_to_be_installed
              }, status: :ok
          end
        # POST /v1/regions
    def create
        
        @region = Region.new(region_params)
        @disco = Disco.find_by(id: params[:itemId]) # Using find_by to get a single record
    
        if @disco
        @region.disco = @disco
        if @region.save
            render json: @region, status: :created
        else
            render json: @region.errors, status: :unprocessable_entity
        end
        else
        render json: { error: "No matching disco found for provided name" }, status: :not_found
        end
    end
    
    
        # PATCH/PUT /v1/regions/:id
        def update
        if @region.update(region_params)
            render json: @region, status: :ok
        else
            render json: @region.errors, status: :unprocessable_entity
        end
        end
    
        # DELETE /v1/regions/:id
        def destroy
        @region.destroy
        head :no_content
        end
    
        # DELETE /v1/regions/multiple
        def delete_regions
        region_ids = params[:ids]
        Region.where(id: region_ids).destroy_all
        head :no_content
        end
    
        private
        # Use callbacks to share common setup or constraints between actions.
        def set_region
            @region = Region.find(params[:id])
        end
    
        # Only allow a trusted parameter "white list" through.
        def region_params
            params.require(:region).permit(:name, :description)
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