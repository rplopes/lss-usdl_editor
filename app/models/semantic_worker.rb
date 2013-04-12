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
    s: 'http://schema.org/',
    'lss-usdl' => ONTOLOGY_URL
  }

  RDFS = RDF::RDFS
  FOAF = RDF::FOAF
  GR   = RDF::Vocabulary.new 'http://purl.org/goodrelations/v1#'
  S    = RDF::Vocabulary.new 'http://schema.org/'
  GN   = RDF::Vocabulary.new 'http://sws.geonames.org/'

  def self.from_db_to_lss_usdl(service_system)
    data = RDF::Vocabulary.new service_system.uri
    graph = RDF::Graph.new

    # Service system
    service_sid = add_entity data, graph, 'ServiceSystem', service_system

    service_system.interactions.each do |interaction|

      # Interactions
      interaction_type = interaction.interaction_type.present? ? interaction.interaction_type : 'Interaction'
      interaction_sid = add_entity data, graph, interaction_type, interaction
      graph << [service_sid, LSS_USDL.hasInteraction, interaction_sid]

      # Roles
      interaction.roles.each do |role|
        role_id = add_entity data, graph, 'Role', role
        graph << [interaction_sid, LSS_USDL.isPerformedBy, role_id]

        # Business entity
        if role.business_entity
          business_entity_id = data[camel_case(role.business_entity.foaf_name)]
          graph << [business_entity_id, RDF.type, GR.BusinessEntity]
          graph << [business_entity_id, FOAF.name, role.business_entity.foaf_name]
          graph << [business_entity_id, FOAF.page, role.business_entity.foaf_page] if role.business_entity.foaf_page.present?
          graph << [business_entity_id, FOAF.logo, role.business_entity.foaf_logo] if role.business_entity.foaf_logo.present?
          graph << [business_entity_id, S.telephone, role.business_entity.s_telephone] if role.business_entity.s_telephone.present?
          graph << [business_entity_id, S.email, role.business_entity.s_email] if role.business_entity.s_email.present?
          graph << [business_entity_id, GR.description, role.business_entity.gr_description] if role.business_entity.gr_description.present?
        end
      end

      # Goals
      interaction.goals.each do |goal|
        goal_sid = add_entity data, graph, 'Goal', goal
        graph << [interaction_sid, LSS_USDL.hasGoal, goal_sid]
      end

      # Processes
      interaction.processes.each do |process|
        process_sid = add_entity data, graph, 'Process', process
        graph << [interaction_sid, LSS_USDL.belongsToProcess, process_sid]
      end

      # Locations
      interaction.locations.each do |location|
        location_sid = add_entity data, graph, 'Location', location
        graph << [interaction_sid, LSS_USDL.hasLocation, location_sid]
        graph << [location_sid, LSS_USDL.isLocationFrom, GN[location.gn_feature.gsub(/[^0-9]*/, '')]] if location.gn_feature.present?
        while location.location_id
          location = location.broader_location
          new_location_sid = add_entity data, graph, 'Location', location
          graph << [new_location_sid, LSS_USDL.isLocationFrom, GN[location.gn_feature.gsub(/[^0-9]*/, '')]] if location.gn_feature.present?
          graph << [location_sid, LSS_USDL.isLocatedIn, new_location_sid]
          location_sid = new_location_sid
        end
      end

      # Resources
      interaction.resources.each do |resource|
        resource_type = resource.resource_type.present? ? resource.resource_type : 'Resource'
        resource_sid = add_entity data, graph, resource_type, resource
        if interaction.received_resources.index(resource)
          resource_connection = 'receivesResource'
        elsif interaction.created_resources.index(resource)
          resource_connection = 'createsResource'
        elsif interaction.consumed_resources.index(resource)
          resource_connection = 'consumesResource'
        elsif interaction.returned_resources.index(resource)
          resource_connection = 'returnsResource'
        end
        graph << [interaction_sid, LSS_USDL[resource_connection], resource_sid]

        if resource.value or resource.max_value or resource.min_value or resource.unit_of_measurement.present?
          # Price specification
          if resource_type == 'FinancialResource'
            value_sid = data["#{camel_case(resource.label)}PriceSpecification"]
            graph << [value_sid, RDF.type, GR.PriceSpecification]
            graph << [value_sid, GR.hasCurrencyValue, resource.value_] if resource.value
            graph << [value_sid, GR.hasMaxCurrencyValue, resource.max_value_] if resource.max_value
            graph << [value_sid, GR.hasMinCurrencyValue, resource.min_value_] if resource.min_value
            graph << [value_sid, GR.hasCurrency, resource.unit_of_measurement] if resource.unit_of_measurement.present?
          # Quantitative value
          else
            value_sid = data["#{camel_case(resource.label)}QuantitativeValue"]
            graph << [value_sid, RDF.type, GR.QuantitativeValue]
            graph << [value_sid, GR.hasValue, resource.value_] if resource.value
            graph << [value_sid, GR.hasMaxValue, resource.max_value_] if resource.max_value
            graph << [value_sid, GR.hasMinValue, resource.min_value_] if resource.min_value
            graph << [value_sid, GR.hasUnitOfMeasurement, resource.unit_of_measurement] if resource.unit_of_measurement.present?
          end
        end
      end

    end

    build_tll graph, service_system
  end

  private

  def self.add_entity(data, graph, type, entity)
    sid = data[camel_case(entity.label)]
    graph << [sid, RDF.type, LSS_USDL[type]]
    graph << [sid, RDFS.label, entity.label]
    graph << [sid, RDFS.comment, entity.comment] if entity.comment.present?
    return sid
  end

  def self.build_tll(graph, service)
    RDF::Writer.for(:ttl).buffer do |writer|
      writer.prefixes = PREFIXES
      writer.prefixes[service.prefix] = service.uri
      graph.each_statement do |statement|
        writer << statement
      end
    end
  end

  def self.camel_case(label)
    str = ""
    label.split(" ").each do |word|
      str += word.capitalize
    end
    return str.gsub /[^a-zA-Z0-9]+/, ""
  end

end