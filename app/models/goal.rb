class Goal < ActiveRecord::Base
  attr_accessible :comment, :label, :service_system_id, :sid
  belongs_to :service_system
end
