class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!, :load_navbar, :load_service_system

  def load_navbar
    @navbar = [ "goals" ]
  end

  def load_service_system
    begin
      @service_system = ServiceSystem.find(params[:service_system_id].to_i)
    rescue
      @service_system = nil
    end
  end

  def camel_case(label)
    str = ""
    label.split(" ").each do |word|
      str += word.capitalize
    end
    return str
  end
end
