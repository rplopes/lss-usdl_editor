class ServiceSystem < ActiveRecord::Base
  attr_accessible :comment, :label, :prefix, :uri
  belongs_to :user
end
