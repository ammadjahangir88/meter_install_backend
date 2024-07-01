# app/controllers/inspections_controller.rb
class V1::InspectionsController < ApplicationController
    before_action :set_inspection, only: %i[ update destroy]
    
    def index
      @inspections = Inspection.all
      render json: @inspections
    end
  
    def show
     
      @inspection = Inspection.find_by(meter_id: params[:id])
      render json: @inspection
    end
  
    def create

      @inspection = Inspection.new(inspection_params)
      @inspection.user=@current_user
      if @inspection.save
        render json: @inspection, status: :created
      else
        render json: @inspection.errors, status: :unprocessable_entity
      end
    end
    
    def inspection_completed
      meter_id = params[:meter_id]
      inspection = Inspection.find_by(meter_id: meter_id)
      
      if inspection
        render json: { completed: true }
      else
        render json: { completed: false }
      end
    end
    def update
      if @inspection.update(inspection_params)
        render json: @inspection
      else
        render json: @inspection.errors, status: :unprocessable_entity
      end
    end
  
    def destroy
      @inspection.destroy
      head :no_content
    end
  
    private
  
    def set_inspection
      @inspection = Inspection.find(params[:id])
    end
  
    def inspection_params
      params.require(:inspection).permit(:meter_id, :user_id, :meter_type_ok, :display_verification_ok, :installation_location_ok, :wiring_connection_ok, :sealing_ok, :documentation_ok, :compliance_assurance_ok, :remarks).tap do |p|
        p[:meter_type_ok] = to_boolean(p[:meter_type_ok])
        p[:display_verification_ok] = to_boolean(p[:display_verification_ok])
        p[:installation_location_ok] = to_boolean(p[:installation_location_ok])
        p[:wiring_connection_ok] = to_boolean(p[:wiring_connection_ok])
        p[:sealing_ok] = to_boolean(p[:sealing_ok])
        p[:documentation_ok] = to_boolean(p[:documentation_ok])
        p[:compliance_assurance_ok] = to_boolean(p[:compliance_assurance_ok])
      end
    end
  
    def to_boolean(value)
      case value
      when 'True'
        true
      when 'False'
        false
      else
        value
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
  