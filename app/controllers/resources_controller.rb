class ResourcesController < ApplicationController
  # GET /resources
  # GET /resources.json
  def index
    if @service_system.present?
      @resources = Resource.where "service_system_id = ?", @service_system.id
    else
      @resources = Resource.all
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @resources }
    end
  end

  # GET /resources/1
  # GET /resources/1.json
  def show
    @resource = Resource.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @resource }
    end
  end

  # GET /resources/new
  # GET /resources/new.json
  def new
    @resource = @service_system.resources.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @resource }
    end
  end

  # GET /resources/1/edit
  def edit
    @resource = Resource.find(params[:id])
  end

  # POST /resources
  # POST /resources.json
  def create
    @resource = Resource.new(params[:resource])
    @resource.sid = camel_case @resource.label
    @resource.service_system = @service_system if @service_system.present?

    respond_to do |format|
      if @resource.save
        format.html { redirect_to service_system_resources_url, notice: 'Resource was successfully created.' }
        format.json { render json: @resource, status: :created, location: @resource }
      else
        format.html { render action: "new" }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /resources/1
  # PUT /resources/1.json
  def update
    @resource = Resource.find(params[:id])
    params[:resource][:sid] = camel_case params[:resource][:label]

    respond_to do |format|
      if @resource.update_attributes(params[:resource])
        format.html { redirect_to service_system_resource_url, notice: 'Resource was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /resources/1
  # DELETE /resources/1.json
  def destroy
    @resource = Resource.find(params[:id])
    @resource.destroy

    respond_to do |format|
      format.html { redirect_to service_system_resources_url }
      format.json { head :no_content }
    end
  end
end
