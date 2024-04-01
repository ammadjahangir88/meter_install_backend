class V1::DiscosController < ApplicationController
    before_action :set_disco, only: [:show, :update, :destroy]
  
    # GET /v1/discos
   def index
    discos = Disco.includes(divisions: { subdivisions: :meters }).all
    render json: discos, include: { 
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
        except: [:created_at, :updated_at, :disco_id]
      }
    }
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
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_disco
        @disco = Disco.find(params[:id])
      end
  
      # Only allow a trusted parameter "white list" through.
      def disco_params
        params.require(:disco).permit(:name)
      end
  end
  