class Goal < ActiveRecord::Base
  attr_accessible :comment, :label, :service_system_id, :sid
  belongs_to :service_system
  has_and_belongs_to_many :interactions

  validates :label, :sid, presence: true
  validates :service_system_id, numericality: { only_integer: true }

  def to_s
    self.label
  end
end
