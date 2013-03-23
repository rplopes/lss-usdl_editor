class BusinessEntity < ActiveRecord::Base
  attr_accessible :foaf_logo, :foaf_name, :foaf_page, :gr_description, :s_email, :s_telephone, :service_system_id, :sid
  belongs_to :service_system
  has_many :roles

  def to_s
    self.foaf_name
  end
end