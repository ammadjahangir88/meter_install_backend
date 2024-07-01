  class V1::SubdivisionsController < ApplicationController
      before_action :set_subdivision, only: [:show, :update, :destroy]
    
      # GET /v1/subdivisions
      def index
        if params[:division_id]
          @subdivisions = Subdivision.where(division_id: params[:division_id])
        else
          @subdivisions = Subdivision.all
        end
        render json: @subdivisions
      end
    
      # GET /v1/subdivisions/:id
      def show
        @subdivision = Subdivision.find(params[:id])
      
        # Calculate metrics for meters in the subdivision
        total_meters = @subdivision.meters.count
        meters_installed = @subdivision.meters.where.not(user_id: nil).count
        meters_qc_done = @subdivision.meters.joins(:inspection).count
        meters_qc_ok = @subdivision.meters.joins(:inspection).where(inspections: { meter_type_ok: true, display_verification_ok: true, installation_location_ok: true, wiring_connection_ok: true, sealing_ok: true, documentation_ok: true, compliance_assurance_ok: true }).count
        meters_qc_remaining = @subdivision.meters.where.not(user_id: nil).left_outer_joins(:inspection).where(inspections: { id: nil }).count
        meters_to_be_installed = total_meters - meters_installed
        name=  @subdivision.name
   
        render json: {
         name: name,
          total_meters: total_meters,
          meters_installed: meters_installed,
          meters_qc_done: meters_qc_done,
          meters_qc_ok: meters_qc_ok,
          meters_qc_remaining: meters_qc_remaining,
          meters_to_be_installed: meters_to_be_installed
              }, status: :ok
      
      end
    
    # POST /v1/subdivisions
  def create
    @subdivision = Subdivision.new(subdivision_params)

    # Assuming 'division_id' is passed as a parameter to find the division
    @division = Division.find_by(id: params[:itemId])

    if @division
      @subdivision.division = @division
      if @subdivision.save
        render json: @subdivision, status: :created
      else
        render json: @subdivision.errors, status: :unprocessable_entity
      end
    else
      render json: { error: "No matching division found for provided ID" }, status: :not_found
    end
  end
    
      # PATCH/PUT /v1/subdivisions/:id
      def update
        if @subdivision.update(subdivision_params)
          render json: @subdivision, status: :ok
        else
          render json: @subdivision.errors, status: :unprocessable_entity
        end
      end
    
      # DELETE /v1/subdivisions/:id
      def destroy
        @subdivision.destroy
        head :no_content
      end
    
      private
        # Use callbacks to share common setup or constraints between actions.
        def set_subdivision
          @subdivision = Subdivision.find(params[:id])
        end
    
        # Only allow a trusted parameter "white list" through.
        def subdivision_params
          params.require(:subdivision).permit(:name, :division_id)
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

    