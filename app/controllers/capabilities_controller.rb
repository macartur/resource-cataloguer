class CapabilitiesController < ApplicationController

  # GET /capabilities
  def index
    type = params[:capability_type]
    if type.nil?
      capabilities = Capability.all
    else
      capabilities = Capability.all_of_function type.to_sym
    end

    if capabilities.count == 0
      render json: {error: "could not find by capability type"}, status: 400
    else
      render json: {capabilities: capabilities}, status: 200
    end
  end

  #POST /capabilities
  def create
    begin
      capability_type = params[:capability_type].try(:to_sym)

      raise Exception.new("Bad capability_type") if capability_type.nil? or not Capability.valid_function?(capability_type)

      capability = Capability.create_with_function(capability_type, create_params)

      raise Exception.new(capability.errors.full_messages.first) if not capability.valid?

      result = Capability.first.to_json(except: :function, methods: :capability_type)

      status = 201
    rescue Exception => e
      result =  { error: e }
      status =  400
    end
    render json: result, status: status
  end

  #PATCH /capabilities/:name
  #PUT /capabilities/:name
  def update
    begin
      capability = Capability.find_by_name params[:name]
      if capability == nil
        raise "name not found"
      end
      capability.update!(update_params)
      result = Capability.first.to_json(except: :function, methods: :capability_type)
      status = 202
    rescue Exception => e
      result = { error: e }
      status = 400
    end
    render json: result, status: status
  end

  #DELETE /capabilities/:id
  def destroy
    capability = Capability.find_by_id params[:id]
    begin
      capability.delete
      render json: {message: "capability deleted"}, status: 200
    rescue
      render json: {error: "no capability found"}, status: 400
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
