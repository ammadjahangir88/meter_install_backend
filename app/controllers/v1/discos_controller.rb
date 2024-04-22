class V1::DiscosController < ApplicationController
    before_action :set_disco, only: [:show, :update, :destroy]
    
    # GET /v1/discos
    def index
      discos = Disco.includes(regions: { divisions: { subdivisions: :meters } }).all
      render json: discos, include: { 
        regions: { 
          include: { 
            divisions: {
              include: {
                subdivisions: {
                  include: {
                    meters: {
                      except: [:created_at, :updated_at, :subdivision_id]
                    }
                  },
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
    
  def all_discos
    @discos=Disco.all
    render json: @discos, status: :ok

  end 
  
    # GET /v1/discos/:id
    def show
      render json: @disco, status: :ok
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
     binding.pry
      disco_ids = params[:ids]
      Disco.where(id: disco_ids).destroy_all
      head :no_content
    end
    def delete_regions
      binding.pry
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
  