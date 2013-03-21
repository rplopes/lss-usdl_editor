class Location < ActiveRecord::Base
  attr_accessible :comment, :gn_feature, :label, :location_id, :service_system_id, :sid
  belongs_to :service_system

  belongs_to :broader_location, :class_name => "Location", :foreign_key => "location_id"
  has_many :narrower_locations, :class_name => "Location", :foreign_key => "location_id"

  def to_s
    self.label
  end
end
