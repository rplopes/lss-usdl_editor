class InteractionsController < ApplicationController
  before_filter :select_tab

  def index
    if params[:view_status] and ["esb", "list"].index(params[:view_status])
      @service_system.view_status = params[:view_status]
      @service_system.save
    end

    @roles = Role.where "service_system_id = ?", @service_system.id
    @goals = Goal.where "service_system_id = ?", @service_system.id
    @locations = Location.where "service_system_id = ?", @service_system.id
    @processes = ProcessEntity.where "service_system_id = ?", @service_system.id
    @resources = Resource.where "service_system_id = ?", @service_system.id
    
    @filter = {
      roles: params[:roles],
      goals: params[:goals],
      locations: params[:locations],
      processes: params[:processes],
      resources: params[:resources]
    }
    if @service_system.view_status == "list"
      @interactions = Interaction.build_interactions_list(@service_system.id, @filter)
      @full_width = false
    else
      @interactions = Interaction.build_interactions_blueprint(@service_system.id, @filter)
      @full_width = true
    end

    respond_to do |format|
      format.html
      format.json { render json: @interactions }
    end
  end

  def show
    @interaction = Interaction.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @interaction }
    end
  end

  def new
    @interaction = @service_system.interactions.build
    @interactions_before_after = Interaction.where "service_system_id = ?", @service_system.id
    @interactions_during = @interactions_before_after

    respond_to do |format|
      format.html
      format.json { render json: @interaction }
    end
  end

  def edit
    @interaction = Interaction.find(params[:id])

    @roles = []
    Role.where("service_system_id = ?", @service_system.id).each do |obj|
      @roles.append obj unless @interaction.roles.index(obj)
    end
    @goals = []
    Goal.where("service_system_id = ?", @service_system.id).each do |obj|
      @goals.append obj unless @interaction.goals.index(obj)
    end
    @locations = []
    Location.where("service_system_id = ?", @service_system.id).each do |obj|
      @locations.append obj unless @interaction.locations.index(obj)
    end
    @processes = []
    ProcessEntity.where("service_system_id = ?", @service_system.id).each do |obj|
      @processes.append obj unless @interaction.processes.index(obj)
    end
    @resources = []
    Resource.where("service_system_id = ?", @service_system.id).each do |obj|
      @resources.append obj unless @interaction.resources.index(obj)
    end
    
    @interactions_before_after = Interaction.where "id != ? and service_system_id = ?", @interaction.id, @service_system.id
    @interactions_during = Interaction.where "id != ? and service_system_id = ? and interaction_type != ?", @interaction.id, @service_system.id, @interaction.interaction_type
  end

  def edit_time
    @interaction = Interaction.find(params[:interaction_id])
  end

  def create
    @interaction = Interaction.new(params[:interaction])
    @interaction.sid = camel_case @interaction.label
    @interaction.service_system = @service_system if @service_system.present?

    respond_to do |format|
      if @interaction.save
        format.html { redirect_to service_system_interactions_url, notice: 'Interaction was successfully created.' }
        format.json { render json: @interaction, status: :created, location: @interaction }
      else
        @interactions_before_after = Interaction.where "service_system_id = ?", @service_system.id
        @interactions_during = @interactions_before_after
        format.html { render action: "new" }
        format.json { render json: @interaction.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @interaction = Interaction.find(params[:id])
    params[:interaction][:sid] = camel_case params[:interaction][:label] if params[:interaction][:label].present?

    respond_to do |format|
      if @interaction.update_attributes(params[:interaction])
        format.html { redirect_to service_system_interaction_url, notice: 'Interaction was successfully updated.' }
        format.json { head :no_content }
      else   
        @interactions_before_after = Interaction.where "id != ? and service_system_id = ?", @interaction.id, @service_system.id
        @interactions_during = Interaction.where "id != ? and service_system_id = ? and interaction_type != ?", @interaction.id, @service_system.id, @interaction.interaction_type
        format.html { render action: "edit" }
        format.json { render json: @interaction.errors, status: :unprocessable_entity }
      end
    end
  end

  def add_entity
    @interaction = Interaction.find(params[:interaction_id])
    if params[:role].present?
      @interaction.roles << Role.find(params[:role])
    elsif params[:goal].present?
      @interaction.goals << Goal.find(params[:goal])
    elsif params[:location].present?
      @interaction.locations << Location.find(params[:location])
    elsif params[:process].present?
      @interaction.processes << ProcessEntity.find(params[:process])
    elsif params[:resource].present?
      @interaction.received_resources << Resource.find(params[:resource]) if params[:relation] == "Receives"
      @interaction.created_resources << Resource.find(params[:resource]) if params[:relation] == "Creates"
      @interaction.consumed_resources << Resource.find(params[:resource]) if params[:relation] == "Consumes"
      @interaction.returned_resources << Resource.find(params[:resource]) if params[:relation] == "Returns"
    end

    respond_to do |format|
      if @interaction.save
        format.html { redirect_to service_system_interaction_url(@service_system.id, @interaction.id), notice: 'Interaction was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @interaction.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @interaction = Interaction.find(params[:id])
    @interaction.destroy

    respond_to do |format|
      format.html { redirect_to service_system_interactions_url }
      format.json { head :no_content }
    end
  end

  def delete_entity
    @interaction = Interaction.find(params[:interaction_id])
    if params[:role].present?
      @interaction.roles.delete(Role.find(params[:role]))
    elsif params[:goal].present?
      @interaction.goals.delete(Goal.find(params[:goal]))
    elsif params[:location].present?
      @interaction.locations.delete(Location.find(params[:location]))
    elsif params[:process].present?
      @interaction.processes.delete(ProcessEntity.find(params[:process]))
    elsif params[:received_resource].present?
      @interaction.received_resources.delete(Resource.find(params[:received_resource]))
    elsif params[:created_resource].present?
      @interaction.created_resources.delete(Resource.find(params[:created_resource]))
    elsif params[:consumed_resource].present?
      @interaction.consumed_resources.delete(Resource.find(params[:consumed_resource]))
    elsif params[:returned_resource].present?
      @interaction.returned_resources.delete(Resource.find(params[:returned_resource]))
    end

    respond_to do |format|
      format.html { redirect_to service_system_interaction_url(@service_system.id, @interaction.id), notice: 'Interaction was successfully updated.' }
      format.json { head :no_content }
    end
  end

  private

  def select_tab
    @tab = {"interactions" => true}
  end
end
