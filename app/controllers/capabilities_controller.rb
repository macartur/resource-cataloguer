class CapabilitiesController < ApplicationController
   


  # GET /capabilities
  def index
    type = params[:capability_type]
    if(type == nil)
      capabilities = Capability.all
    elsif(type == "sensor")
      capabilities = Capability.where(function: 0)
    elsif(type == "actuator")
      capabilities = Capability.where(function: 1)
    elsif(type == "information")
      capabilities = Capability.where(function: 2)
    else
      capabilities = "could not find by capability type"
    end
    if (capabilities.is_a? String)
      render json: { error: capabilities  } ,status: 400
    else
      render json: { capabilities: capabilities  } ,status: 200
    end
  end


  #POST /capabilities
  def create
    begin
      capability_type = params[:capability_type]
      puts params.inspect
      if capability_type == "sensor"
        capability = Capability.create_sensor(create_params)
        puts capability
      elsif capability_type == "actuator"
        capability = Capability.create_actuator(create_params)
        puts capability
      elsif capability_type == "information"
        capability = Capability.create_information(create_params)
        puts capability
      end
    rescue Exception => e
      render json: { erro: e  }, status: 400
    end
    render json: { capability: capability } , status: 201
  end 





  #PATCH /capabilities/:name
  #PUT /capabilities/:name
  def update
    
    begin
      
      capability = Capability.find_by_name params[:name]
      capability.update!(update_params)
      render json: { capability: capability}, status: 201
    rescue Exception => e
      puts e.message
      render json: {error: e }, status: 400
    end
  end


  #DELETE /capabilities/:id
  def destroy
    capability = Capability.find_by_id params[:id]
    begin
      capability.delete
    rescue
      render json: {error: "No capability found"}, status: 400
    end
  end 






  private
    def create_params
	    params.permit(:name, :description)
    end
    def update_params
      params.permit(:name, :description )
    end
end
