class LocationsController < ApplicationController
  before_filter :select_tab

  def index
    if @service_system.present?
      @locations = Location.where "service_system_id = ?", @service_system.id
    else
      @locations = Location.all
    end

    respond_to do |format|
      format.html
      format.json { render json: @locations }
    end
  end

  def show
    @location = Location.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @location }
    end
  end

  def new
    @location = @service_system.locations.build
    @locations = Location.where "service_system_id = ?", @service_system.id

    respond_to do |format|
      format.html
      format.json { render json: @location }
    end
  end

  def edit
    @location = Location.find(params[:id])
    @locations = Location.where "service_system_id = ? and id != ?", @service_system.id, @location.id
  end

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
