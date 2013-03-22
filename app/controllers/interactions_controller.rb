class InteractionsController < ApplicationController
  # GET /interactions
  # GET /interactions.json
  def index
    if @service_system.present?
      @interactions = Interaction.where "service_system_id = ?", @service_system.id
    else
      @interactions = Interaction.all
    end
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

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @interaction }
    end
  end

  # GET /interactions/new
  # GET /interactions/new.json
  def new
    @interaction = @service_system.interactions.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @interaction }
    end
  end

  # GET /interactions/1/edit
  def edit
    @interaction = Interaction.find(params[:id])
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
end
