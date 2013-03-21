class ServiceSystem < ActiveRecord::Base
  attr_accessible :comment, :label, :prefix, :uri, :user_id
  belongs_to :user

  has_many :business_entities
  has_many :roles

  has_many :goals

  has_many :process_entities

  has_many :resources
end
