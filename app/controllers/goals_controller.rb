class GoalsController < ApplicationController
  before_filter :select_tab

  def index
    if @service_system.present?
      @goals = Goal.where "service_system_id = ?", @service_system.id
    else
      @goals = Goal.all
    end

    respond_to do |format|
      format.html
      format.json { render json: @goals }
    end
  end

  def show
    @goal = Goal.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @goal }
    end
  end

  def new
    @goal = @service_system.goals.build

    respond_to do |format|
      format.html
      format.json { render json: @goal }
    end
  end

  def edit
    @goal = Goal.find(params[:id])
  end

  def create
    @goal = Goal.new(params[:goal])
    @goal.sid = camel_case @goal.label
    @goal.service_system = @service_system if @service_system.present?

    respond_to do |format|
      if @goal.save
        format.html { redirect_to service_system_goals_url, notice: 'Goal was successfully created.' }
        format.json { render json: @goal, status: :created, location: @goal }
      else
        format.html { render action: "new" }
        format.json { render json: @goal.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @goal = Goal.find(params[:id])
    params[:goal][:sid] = camel_case params[:goal][:label]

    respond_to do |format|
      if @goal.update_attributes(params[:goal])
        format.html { redirect_to service_system_goal_url, notice: 'Goal was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @goal.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @goal = Goal.find(params[:id])
    @goal.destroy

    respond_to do |format|
      format.html { redirect_to service_system_goals_url }
      format.json { head :no_content }
    end
  end

  private

  def select_tab
    @tab = {"goals" => true}
  end
end
