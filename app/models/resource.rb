class Resource < ActiveRecord::Base
  attr_accessible :comment, :label, :max_value, :min_value, :resource_type, :service_system_id, :sid, :unit_of_measurement, :value
  belongs_to :service_system
  has_and_belongs_to_many :interactions_receiving, class_name: "Interaction", join_table: "interactions_receives_resources"
  has_and_belongs_to_many :interactions_creating, class_name: "Interaction", join_table: "interactions_creates_resources"
  has_and_belongs_to_many :interactions_consuming, class_name: "Interaction", join_table: "interactions_consumes_resources"
  has_and_belongs_to_many :interactions_returning, class_name: "Interaction", join_table: "interactions_returns_resources"

  validates :label, :sid, presence: true
  validates :max_value, numericality: true, allow_nil: true
  validates :min_value, numericality: true, allow_nil: true
  validates :value, numericality: true, allow_nil: true
  validates :service_system_id, numericality: { only_integer: true }

  def to_s
    self.label
  end

  def self.subclasses
    [ "Physical", "Knowledge", "Financial" ]
  end

  def value_
    if self.value
      return self.value.to_i == self.value ? self.value.to_i : self.value
    end
  end
  def max_value_
    if self.max_value
      return self.max_value.to_i == self.max_value ? self.max_value.to_i : self.max_value
    end
  end
  def min_value_
    if self.min_value
      return self.min_value.to_i == self.min_value ? self.min_value.to_i : self.min_value
    end
  end
end
