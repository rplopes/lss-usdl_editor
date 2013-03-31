class ProcessEntity < ActiveRecord::Base
  attr_accessible :comment, :label, :service_system_id, :sid
  belongs_to :service_system
  has_and_belongs_to_many :interactions, class_name: "Interaction", join_table: "interactions_processes"

  def to_s
    self.label
  end
end
