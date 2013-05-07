class ServiceSystemsController < ApplicationController
  before_filter :select_metadata_tab

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
    redirect_to service_system_interactions_url(params[:id])
    #@service_system = ServiceSystem.find(params[:id])

    #respond_to do |format|
    #  format.html # show.html.erb
    #  format.json { render json: @service_system }
    #end
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

    @service_system.interactions.each { |o| o.destroy }
    @service_system.roles.each { |o| o.destroy }
    @service_system.business_entities.each { |o| o.destroy }
    @service_system.goals.each { |o| o.destroy }
    @service_system.locations.each { |o| o.destroy }
    @service_system.process_entities.each { |o| o.destroy }
    @service_system.resources.each { |o| o.destroy }

    @service_system.destroy

    respond_to do |format|
      format.html { redirect_to service_systems_url }
      format.json { head :no_content }
    end
  end

  def export_to_lss_usdl
    @service_system = ServiceSystem.find(params[:service_system_id])
    send_data SemanticWorker.from_db_to_lss_usdl(@service_system),
          :disposition => "attachment; filename=#{@service_system.label}.ttl"
  end

  def import
    if params[:type] == "LSS-USDL"
      @service_system = SemanticWorker.from_lss_usdl_to_db(params[:file], current_user)
    else
      #TODO @service_system = SemanticWorker.from_linked_usdl_to_db(params[:file])
    end

    respond_to do |format|
      if @service_system
        format.html { redirect_to @service_system, notice: 'Service system was successfully created.' }
        format.json { render json: @service_system, status: :created, location: @service_system }
      else
        format.html { redirect_to service_systems_url, alert: 'Service system could not be imported from that file.' }
        format.json { render json: @service_system.errors, status: :unprocessable_entity }
      end
    end
  end

  def export_to_linked_usdl
    @service_system = ServiceSystem.find(params[:service_system_id])
    send_data SemanticWorker.from_db_to_linked_usdl(@service_system),
          :disposition => "attachment; filename=#{@service_system.label} - Linked USDL.ttl"
  end

  private

  def select_metadata_tab
    @metadata_tab = true
  end
end
