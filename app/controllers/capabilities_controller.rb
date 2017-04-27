class CapabilitiesController < ApplicationController
   


  # GET /capabilities
  def index

    capabilities = Capability.all



    render json: { capabilities: capabilities  } ,status: 200
  end


  #POST /capabilities
  def create
    stat =201
    capability_type = params[:capability_type]
    puts "*"* 10000
    puts params.inspect
    if capability_type == "sensor"
      capability = Capability.create_sensor(create_params)
      puts capability
    elsif capability_type == "actuator"
      capability = Capability.create_actuator(create_params)
      puts capability
    else
   	  stat = 400
   	  capability = { erro:  "invalid capability_type  #{capability_type}"  }
    end
    render json: { capability: capability } , status: stat
  end 





  #PATCH /capabilities/:name
  def update
    status =201
    capability_name, capability_description = update_params
    capability = Capability.find_by_name capability_name
    capability.description = capability_description


    

    render json: { capability: capability}, status = status
  end


  private
    def create_params
	    params.permit(:name, :description)
    end
    def update_params
      params.permit(:name, :description)
    end
end
