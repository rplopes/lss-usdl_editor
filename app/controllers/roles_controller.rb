class RolesController < ApplicationController
  # GET /roles
  # GET /roles.json
  def index
    if @service_system.present?
      @roles = Role.where "service_system_id = ?", @service_system.id
    else
      @roles = Role.all
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @roles }
    end
  end

  # GET /roles/1
  # GET /roles/1.json
  def show
    @role = Role.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @role }
    end
  end

  # GET /roles/new
  # GET /roles/new.json
  def new
    @role = @service_system.roles.build
    @business_entities = BusinessEntity.where "service_system_id = ?", @service_system.id

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @role }
    end
  end

  # GET /roles/1/edit
  def edit
    @role = Role.find(params[:id])
    @business_entities = BusinessEntity.where "service_system_id = ?", @service_system.id
  end

  # POST /roles
  # POST /roles.json
  def create
    @role = Role.new(params[:role])
    @role.sid = camel_case @role.label
    @role.service_system = @service_system if @service_system.present?

    respond_to do |format|
      if @role.save
        format.html { redirect_to service_system_roles_url, notice: 'Role was successfully created.' }
        format.json { render json: @role, status: :created, location: @role }
      else
        format.html { render action: "new" }
        format.json { render json: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /roles/1
  # PUT /roles/1.json
  def update
    @role = Role.find(params[:id])
    params[:role][:sid] = camel_case params[:role][:label]

    respond_to do |format|
      if @role.update_attributes(params[:role])
        format.html { redirect_to service_system_role_url, notice: 'Role was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /roles/1
  # DELETE /roles/1.json
  def destroy
    @role = Role.find(params[:id])
    @role.destroy

    respond_to do |format|
      format.html { redirect_to service_system_roles_url }
      format.json { head :no_content }
    end
  end
end
