class Resource < ActiveRecord::Base
  attr_accessible :comment, :label, :max_value, :min_value, :resource_type, :service_system_id, :sid, :unit_of_measurement, :value
  belongs_to :service_system
  has_and_belongs_to_many :interactions_receiving, class_name: "Interaction", join_table: "interactions_receives_resources"
  has_and_belongs_to_many :interactions_creating, class_name: "Interaction", join_table: "interactions_creates_resources"
  has_and_belongs_to_many :interactions_consuming, class_name: "Interaction", join_table: "interactions_consumes_resources"
  has_and_belongs_to_many :interactions_returning, class_name: "Interaction", join_table: "interactions_returns_resources"

  def self.subclasses
    [ "Physical", "Knowledge", "Financial" ]
  end
end
