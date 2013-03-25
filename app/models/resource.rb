class Resource < ActiveRecord::Base
  attr_accessible :comment, :label, :max_value, :min_value, :resource_type, :service_system_id, :sid, :unit_of_measurement, :value
  belongs_to :service_system

  def self.subclasses
    [ "Physical", "Knowledge", "Financial" ]
  end
end
