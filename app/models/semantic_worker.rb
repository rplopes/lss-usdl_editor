class SemanticWorker < ActiveRecord::Base

  LSS_USDL = RDF::Vocabulary.new 'http://rdf.genssiz.dei.uc.pt/lss-usdl#'

  def self.from_db_to_lss_usdl(service)

    data = RDF::Vocabulary.new service.uri
    graph = RDF::Graph.new

    graph << [data[camel_case(service.label)], RDF.type, LSS_USDL.ServiceSystem]
    graph << [data[camel_case(service.label)], RDF.label, service.label]

    graph.dump :ttl
  end

  private

  def self.camel_case(label)
    str = ""
    label.split(" ").each do |word|
      str += word.capitalize
    end
    return str.gsub /[^a-zA-Z0-9]+/, ""
  end

end