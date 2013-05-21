class ResourcesController < ApplicationController
  before_filter :select_tab

  def index
    if @service_system.present?
      @resources = Resource.where "service_system_id = ?", @service_system.id
    else
      @resources = Resource.all
    end

    respond_to do |format|
      format.html
      format.json { render json: @resources }
    end
  end

  def show
    @resource = Resource.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @resource }
    end
  end

  def new
    @resource = @service_system.resources.build

    respond_to do |format|
      format.html
      format.json { render json: @resource }
    end
  end

  def edit
    @resource = Resource.find(params[:id])
  end

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

  def destroy
    @resource = Resource.find(params[:id])
    @resource.destroy

    respond_to do |format|
      format.html { redirect_to service_system_resources_url }
      format.json { head :no_content }
    end
  end

  private

  def select_tab
    @tab = {"resources" => true}
  end
end
