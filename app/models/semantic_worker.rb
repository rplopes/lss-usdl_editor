class SemanticWorker < ActiveRecord::Base

  def self.from_db_to_lss_usdl(service)
    "This is the future LSS-USDL file for the service system #{service.label}"
  end

end