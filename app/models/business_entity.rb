class BusinessEntity < ActiveRecord::Base
  attr_accessible :foaf_logo, :foaf_name, :foaf_page, :gr_description, :s_email, :s_telephone, :service_system_id, :sid
  belongs_to :service_system
  has_many :roles

  validates :foaf_name, :sid, presence: true
  validates_format_of :foaf_logo, with: URI::regexp(%w(http https)), allow_blank: true
  validates_format_of :foaf_page, with: URI::regexp(%w(http https)), allow_blank: true
  validates :s_email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }, allow_blank: true
  validates :service_system_id, numericality: { only_integer: true }

  def to_s
    self.foaf_name
  end
end
