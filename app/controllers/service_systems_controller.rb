class ServiceSystemsController < ApplicationController
  # GET /service_systems
  # GET /service_systems.json
  def index
    @service_systems = ServiceSystem.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @service_systems }
    end
  end

  # GET /service_systems/1
  # GET /service_systems/1.json
  def show
    @service_system = ServiceSystem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @service_system }
    end
  end

  # GET /service_systems/new
  # GET /service_systems/new.json
  def new
    @service_system = ServiceSystem.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @service_system }
    end
  end

  # GET /service_systems/1/edit
  def edit
    @service_system = ServiceSystem.find(params[:id])
    redirect_to action: :show if current_user != @service_system.user
  end

  # POST /service_systems
  # POST /service_systems.json
  def create
    @service_system = ServiceSystem.new(params[:service_system])
    @service_system.user = current_user # add creator

    respond_to do |format|
      if @service_system.save
        format.html { redirect_to @service_system, notice: 'Service system was successfully created.' }
        format.json { render json: @service_system, status: :created, location: @service_system }
      else
        format.html { render action: "new" }
        format.json { render json: @service_system.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /service_systems/1
  # PUT /service_systems/1.json
  def update
    @service_system = ServiceSystem.find(params[:id])

    respond_to do |format|
      if @service_system.user == current_user and @service_system.update_attributes(params[:service_system])
        format.html { redirect_to @service_system, notice: 'Service system was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @service_system.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /service_systems/1
  # DELETE /service_systems/1.json
  def destroy
    @service_system = ServiceSystem.find(params[:id])
    redirect_to action: :show and return if current_user != @service_system.user
    @service_system.destroy

    respond_to do |format|
      format.html { redirect_to service_systems_url }
      format.json { head :no_content }
    end
  end
end
