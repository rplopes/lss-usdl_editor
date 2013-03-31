class Location < ActiveRecord::Base
  attr_accessible :comment, :gn_feature, :label, :location_id, :service_system_id, :sid
  belongs_to :service_system
  has_and_belongs_to_many :interactions

  belongs_to :broader_location, :class_name => "Location", :foreign_key => "location_id"
  has_many :narrower_locations, :class_name => "Location", :foreign_key => "location_id"

  validates :label, :sid, presence: true
  validates :location_id, numericality: { only_integer: true }, allow_nil: true
  validates :service_system_id, numericality: { only_integer: true }

  def to_s
    self.label
  end
end
