class BusinessEntitiesController < ApplicationController
  # GET /business_entities
  # GET /business_entities.json
  def index
    if @service_system.present?
      @business_entities = BusinessEntity.where "service_system_id = ?", @service_system.id
    else
      @business_entities = BusinessEntity.all
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @business_entities }
    end
  end

  # GET /business_entities/1
  # GET /business_entities/1.json
  def show
    @business_entity = BusinessEntity.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @business_entity }
    end
  end

  # GET /business_entities/new
  # GET /business_entities/new.json
  def new
    @business_entity = @service_system.business_entities.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @business_entity }
    end
  end

  # GET /business_entities/1/edit
  def edit
    @business_entity = BusinessEntity.find(params[:id])
  end

  # POST /business_entities
  # POST /business_entities.json
  def create
    @business_entity = BusinessEntity.new(params[:business_entity])
    @business_entity.sid = camel_case @business_entity.foaf_name
    @business_entity.service_system = @service_system if @service_system.present?

    respond_to do |format|
      if @business_entity.save
        format.html { redirect_to service_system_business_entities_url, notice: 'Business entity was successfully created.' }
        format.json { render json: @business_entity, status: :created, location: @business_entity }
      else
        format.html { render action: "new" }
        format.json { render json: @business_entity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /business_entities/1
  # PUT /business_entities/1.json
  def update
    @business_entity = BusinessEntity.find(params[:id])
    params[:business_entity][:sid] = camel_case params[:business_entity][:foaf_name]

    respond_to do |format|
      if @business_entity.update_attributes(params[:business_entity])
        format.html { redirect_to service_system_business_entity_url, notice: 'Business entity was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @business_entity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /business_entities/1
  # DELETE /business_entities/1.json
  def destroy
    @business_entity = BusinessEntity.find(params[:id])
    @business_entity.destroy

    respond_to do |format|
      format.html { redirect_to service_system_business_entities_url }
      format.json { head :no_content }
    end
  end
end
