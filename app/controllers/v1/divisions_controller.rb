    class V1::DivisionsController < ApplicationController
        before_action :set_division, only: [:show, :update, :destroy]
      
        # GET /v1/divisions
        def index
          if params[:region_id]
            @divisions = Division.where(region_id: params[:region_id])
          else
            @divisions = Division.all
          end
          render json: @divisions
        end
      
        # GET /v1/divisions/:id
        def show
          render json: @division, status: :ok
        end
        def meters
          division = Division.find(params[:id])
          meters = division.meters.includes(:subdivision)  # Adjust based on your actual association path
      
          render json: meters, include: [:subdivision], methods: [:new_meter_number, :full_name, :address], status: :ok
        rescue ActiveRecord::RecordNotFound
          render json: { error: "Division not found" }, status: :not_found
        end
      # POST /v1/divisions
    def create
      @division = Division.new(division_params)

      # Assuming 'region_name' is passed as a parameter to find the region
      @region = Region.find_by(id: params[:itemId])
      
      if @region
        @division.region = @region
        if @division.save
          render json: @division, status: :created
        else
          render json: @division.errors, status: :unprocessable_entity
        end
      else
        render json: { error: "No matching region found for provided name" }, status: :not_found
      end
    end

      
        # PATCH/PUT /v1/divisions/:id
        def update
          if @division.update(division_params)
            render json: @division, status: :ok
          else
            render json: @division.errors, status: :unprocessable_entity
          end
        end
      
        # DELETE /v1/divisions/:id
        def destroy
          @division.destroy
          head :no_content
        end
      
        private
          # Use callbacks to share common setup or constraints between actions.
          def set_division
            @division = Division.find(params[:id])
          end
      
          # Only allow a trusted parameter "white list" through.
          def division_params
            params.require(:division).permit(:name, :circle_id)
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
      
