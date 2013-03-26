class InteractionsController < ApplicationController
  before_filter :select_interactions_tab

  # GET /interactions
  # GET /interactions.json
  def index
    @interactions = Interaction.build_interactions_blueprint(@service_system.id)
    @full_width = true

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @interactions }
    end
  end

  # GET /interactions/1
  # GET /interactions/1.json
  def show
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

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @interaction }
    end
  end

  # GET /interactions/new
  # GET /interactions/new.json
  def new
    @interaction = @service_system.interactions.build
    @interactions_before_after = Interaction.where "service_system_id = ?", @service_system.id
    @interactions_during = @interactions_before_after

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @interaction }
    end
  end

  # GET /interactions/1/edit
  def edit
    @interaction = Interaction.find(params[:id])
    @interactions_before_after = Interaction.where "id != ? and service_system_id = ?", @interaction.id, @service_system.id
    @interactions_during = Interaction.where "id != ? and service_system_id = ? and interaction_type != ?", @interaction.id, @service_system.id, @interaction.interaction_type
  end

  # POST /interactions
  # POST /interactions.json
  def create
    @interaction = Interaction.new(params[:interaction])
    @interaction.sid = camel_case @interaction.label
    @interaction.service_system = @service_system if @service_system.present?

    respond_to do |format|
      if @interaction.save
        format.html { redirect_to service_system_interactions_url, notice: 'Interaction was successfully created.' }
        format.json { render json: @interaction, status: :created, location: @interaction }
      else
        format.html { render action: "new" }
        format.json { render json: @interaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /interactions/1
  # PUT /interactions/1.json
  def update
    @interaction = Interaction.find(params[:id])
    params[:interaction][:sid] = camel_case params[:interaction][:label]

    respond_to do |format|
      if @interaction.update_attributes(params[:interaction])
        format.html { redirect_to service_system_interaction_url, notice: 'Interaction was successfully updated.' }
        format.json { head :no_content }
      else
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

  # DELETE /interactions/1
  # DELETE /interactions/1.json
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
    end

    respond_to do |format|
      format.html { redirect_to service_system_interaction_url(@service_system.id, @interaction.id), notice: 'Interaction was successfully updated.' }
      format.json { head :no_content }
    end
  end

  private

  def select_interactions_tab
    @interactions_tab = true
  end
end
