class V1::SubdivisionsController < ApplicationController
    before_action :set_subdivision, only: [:show, :update, :destroy]
  
    # GET /v1/subdivisions
    def index
      @subdivisions = Subdivision.all
      render json: @subdivisions, status: :ok
    end
  
    # GET /v1/subdivisions/:id
    def show
      render json: @subdivision, status: :ok
    end
  
    # POST /v1/subdivisions
    def create
      @subdivision = Subdivision.new(subdivision_params)
  
      if @subdivision.save
        render json: @subdivision, status: :created
      else
        render json: @subdivision.errors, status: :unprocessable_entity
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
  end

  