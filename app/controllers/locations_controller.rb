class LocationsController < ApplicationController
  before_filter :select_tab

  # GET /locations
  # GET /locations.json
  def index
    if @service_system.present?
      @locations = Location.where "service_system_id = ?", @service_system.id
    else
      @locations = Location.all
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @locations }
    end
  end

  # GET /locations/1
  # GET /locations/1.json
  def show
    @location = Location.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @location }
    end
  end

  # GET /locations/new
  # GET /locations/new.json
  def new
    @location = @service_system.locations.build
    @locations = Location.where "service_system_id = ?", @service_system.id

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @location }
    end
  end

  # GET /locations/1/edit
  def edit
    @location = Location.find(params[:id])
    @locations = Location.where "service_system_id = ? and id != ?", @service_system.id, @location.id
  end

  # POST /locations
  # POST /locations.json
  def create
    @location = Location.new(params[:location])
    @location.sid = camel_case @location.label
    @location.service_system = @service_system if @service_system.present?

    respond_to do |format|
      if @location.save
        format.html { redirect_to service_system_locations_url, notice: 'Location was successfully created.' }
        format.json { render json: @location, status: :created, location: @location }
      else
        @locations = Location.where "service_system_id = ? and id != ?", @service_system.id, @location.id
        format.html { render action: "new" }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /locations/1
  # PUT /locations/1.json
  def update
    @location = Location.find(params[:id])
    params[:location][:sid] = camel_case params[:location][:label]

    respond_to do |format|
      if @location.update_attributes(params[:location])
        format.html { redirect_to service_system_location_url, notice: 'Location was successfully updated.' }
        format.json { head :no_content }
      else
        @locations = Location.where "service_system_id = ? and id != ?", @service_system.id, @location.id
        format.html { render action: "edit" }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /locations/1
  # DELETE /locations/1.json
  def destroy
    @location = Location.find(params[:id])
    @location.destroy

    respond_to do |format|
      format.html { redirect_to service_system_locations_url }
      format.json { head :no_content }
    end
  end

  private

  def select_tab
    @tab = {"locations" => true}
  end
end
