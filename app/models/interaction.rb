class Interaction < ActiveRecord::Base
  attr_accessible :comment, :interaction_type, :label, :service_system_id, :sid
  belongs_to :service_system
end
