class ServiceSystem < ActiveRecord::Base
  attr_accessible :comment, :label, :prefix, :uri, :user_id
  belongs_to :user

  has_many :business_entities
  has_many :roles
  has_many :goals
  has_many :locations
  has_many :process_entities
  has_many :resources

  has_many :interactions

  validates :label, :uri, presence: true
  validates :uri, uniqueness: true
  validates_format_of :uri, :with => URI::regexp(%w(http https))
  validates :user_id, numericality: { only_integer: true }
end
