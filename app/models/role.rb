class Role < ActiveRecord::Base
  attr_accessible :comment, :label, :business_entity_id, :service_system_id, :sid
  belongs_to :service_system
  belongs_to :business_entity
  has_and_belongs_to_many :interactions

  def to_s
    self.label
  end
end
