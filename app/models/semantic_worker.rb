class SemanticWorker < ActiveRecord::Base

  ONTOLOGY_URL = 'http://rdf.genssiz.dei.uc.pt/lss-usdl#'

  LSS_USDL = RDF::Vocabulary.new ONTOLOGY_URL
  PREFIXES = {
    rdf: 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
    owl: 'http://www.w3.org/2002/07/owl#',
    xsd: 'http://www.w3.org/2001/XMLSchema#',
    rdfs: 'http://www.w3.org/2000/01/rdf-schema#',
    gr: 'http://purl.org/goodrelations/v1#',
    foaf: 'http://xmlns.com/foaf/0.1/',
    time: 'http://www.w3.org/2006/time#',
    gn: 'http://www.geonames.org/ontology#',
    'lss-usdl' => ONTOLOGY_URL
  }

  def self.from_db_to_lss_usdl(service)

    data = RDF::Vocabulary.new service.uri
    graph = RDF::Graph.new

    graph << [data[camel_case(service.label)], RDF.type, LSS_USDL.ServiceSystem]
    graph << [data[camel_case(service.label)], RDF::RDFS.label, service.label]

    RDF::Writer.for(:ttl).buffer do |writer|
      writer.prefixes = PREFIXES
      writer.prefixes[service.prefix] = service.uri
      graph.each_statement do |statement|
        writer << statement
      end
    end

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