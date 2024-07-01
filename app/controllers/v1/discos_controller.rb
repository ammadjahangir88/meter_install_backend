class V1::DiscosController < ApplicationController
    before_action :set_disco, only: [:show, :update, :destroy]
    before_action :set_pagination_params, only: [:meters_list]

    # GET /v1/discos
    def index
      discos = Disco.includes(regions: { divisions: :subdivisions }).all
      render json: discos, include: {
        regions: {
          include: {
            divisions: {
              include: {
                subdivisions: {
                  except: [:created_at, :updated_at, :division_id]
                }
              },
              except: [:created_at, :updated_at, :region_id]
            }
          },
          except: [:created_at, :updated_at, :disco_id]
        }
      }
    end
  
    def meters_list
      
      subdivision_id = params[:subdivision_id]
      division_id = params[:division_id]
      region_id = params[:region_id]
      disco_id = params[:disco_id]
      meter_no = params[:meter_no]
      ref_no = params[:ref_no]
      connection_type = params[:connection_type]
      telco = params[:telco]
      status = params[:status]
    
      meters = if subdivision_id
                 Subdivision.find(subdivision_id).meters
               elsif division_id
                 Division.find(division_id).meters
               elsif region_id
                 Region.find(region_id).meters
               elsif disco_id
                 Disco.find(disco_id).meters
               else
                 Meter.all
               end
    
      meters = meters.where("NEW_METER_NUMBER LIKE ?", "%#{meter_no}%") if meter_no.present?
      meters = meters.where("REF_NO LIKE ?", "%#{ref_no}%") if ref_no.present?
      meters = meters.where("CONNECTION_TYPE = ?", connection_type) if connection_type.present?
      meters = meters.where("TELCO = ?", telco) if telco.present?
      meters = meters.where("METER_STATUS = ?", status) if status.present?
    
      meters = meters.page(params[:page]).per(params[:per_page])
    
      render json: {
        meters: meters.as_json(except: [:created_at, :updated_at, :subdivision_id]),
        total_pages: meters.total_pages,
        current_page: meters.current_page
      }
    end
  
  #   def meters
  #     entity_type = params[:entity_type]
  #     entity_id = params[:entity_id]
  #     page = params[:page] || 1
  #     per_page = params[:per_page] || 20
  
  #     meters = case entity_type
  #              when 'disco'
  #                Disco.find(entity_id).meters.page(page).per(per_page)
  #              when 'region'
  #                Region.find(entity_id).meters.page(page).per(per_page)
  #              when 'division'
  #                Division.find(entity_id).meters.page(page).per(per_page)
  #              when 'subdivision'
  #                Subdivision.find(entity_id).meters.page(page).per(per_page)
  #              else
  #                []
  #              end
  
  #     render json: meters, except: [:created_at, :updated_at, :subdivision_id]
  #   end
  # end
    
  def disco_dashboard

    discos = Disco.all
   
    disco_data = discos.map do |disco|
      {
        id: disco.id,
        name: disco.name,
        value: disco.meters.count
      }
    end

    render json: { discos: disco_data }, status: :ok
  end
  def all_discos
    @discos=Disco.all
    # @division=Division.all
    # @subdivision=Subdivision.all
    # @user=User.all
    # @meter=Meter.all
    # render json: {
    #   discos:  @discos,
    #   division: @division,
    #   subdivision:  @subdivision,
    #   meter:  @meter
    # }, status: :ok
    render json: @discos, status: :ok

  end 
  
    # GET /v1/discos/:id
    def show
      @disco = Disco.find(params[:id])
      
      regions_data = @disco.regions.includes(:meters).map do |region|
        {
          id: region.id,
          name: region.name,
          value: region.meters.count
        }
      end
  
      total_meters = @disco.meters.count
      meters_installed = @disco.meters.where.not(user_id: nil).count
      meters_qc_done = @disco.meters.joins(:inspection).count
      meters_qc_ok = @disco.meters.joins(:inspection).where(inspections: { meter_type_ok: true, display_verification_ok: true, installation_location_ok: true, wiring_connection_ok: true, sealing_ok: true, documentation_ok: true, compliance_assurance_ok: true }).count
      meters_qc_remaining = @disco.meters.where.not(user_id: nil).left_outer_joins(:inspection).where(inspections: { id: nil }).count
      meters_to_be_installed = total_meters - meters_installed
  
      render json: {
        disco: @disco,
        regionsData: regions_data,
        totalMeters: total_meters,
        metersInstalled: meters_installed,
        metersQCDone: meters_qc_done,
        metersQCOK: meters_qc_ok,
        metersQCRemaining: meters_qc_remaining,
        metersToBeInstalled: meters_to_be_installed
      }, status: :ok
    end
  
    # POST /v1/discos
    def create
    
      @disco = Disco.new(disco_params)
  
      if @disco.save
        render json: @disco, status: :created
      else
        render json: @disco.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /v1/discos/:id
    def update
      if @disco.update(disco_params)
        render json: @disco, status: :ok
      else
        render json: @disco.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /v1/discos/:id
    def destroy
      @disco.destroy
      head :no_content
    end
    def delete_discos
    
      disco_ids = params[:ids]
      Disco.where(id: disco_ids).destroy_all
      head :no_content
    end
    def delete_regions
    
      region_ids = params[:ids]
      Region.where(id: region_ids).destroy_all
      head :no_content
    end
  
    # DELETE /v1/divisions
    def delete_divisions
    
      division_ids = params[:ids]
      Division.where(id: division_ids).destroy_all
      head :no_content
    end
  
    # DELETE /v1/subdivisions
    def delete_subdivisions
      subdivision_ids = params[:ids]
      Subdivision.where(id: subdivision_ids).destroy_all
      head :no_content
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_disco
        @disco = Disco.find(params[:id])
      end
  
      # Only allow a trusted parameter "white list" through.
      def disco_params
        params.require(:disco).permit(:name)
      end
     
      def set_pagination_params
        params[:page] ||= 1
        params[:per_page] ||= 15
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
  