class V1::DivisionsController < ApplicationController
    before_action :set_division, only: [:show, :update, :destroy]
  
    # GET /v1/divisions
    def index
      @divisions = Division.includes(:disco).all
  divisions_json = @divisions.map do |division|
    {
      id: division.id,
      name: division.name,
      disco_id: division.disco_id,
      created_at: division.created_at,
      updated_at: division.updated_at,
      disco: division.disco.name  # Extracting only the name of the disco
    }
  end
  render json: divisions_json, status: :ok
    end
  
    # GET /v1/divisions/:id
    def show
      render json: @division, status: :ok
    end
  
    # POST /v1/divisions
    def create
      @division = Division.new(division_params)
  
      if @division.save
        render json: @division, status: :created
      else
        render json: @division.errors, status: :unprocessable_entity
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
  
