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
  TIME = RDF::Vocabulary.new 'http://www.w3.org/2006/time#'

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

      # Time
      time = RDF::Node.new "#{interaction_sid}Time"
      graph << [interaction_sid, LSS_USDL.hasTime, time]
      graph << [time, RDF.type, LSS_USDL.Time]
      # Temporal entity
      te_sid = data["#{camel_case(interaction.label)}Time"]
      te_type = "TemporalEntity"
      if interaction.temporal_entity_type.present?
        if interaction.temporal_entity_type == "Interval"
          if interaction.time_description.present?
            te_type = "DateTimeInterval"
          else
            te_type = "Interval"
          end
        else
          te_type = "Instant"
        end
      end
      graph << [time, LSS_USDL.hasTemporalEntity, te_sid]
      graph << [te_sid, RDF.type, TIME[te_type]]
      if interaction.time_description.present?
        time_description = RDF::Node.new "#{interaction_sid}DateTimeDescription"
        time_property = te_type == "Instant" ? "inDateTime" : "hasDateTimeDescription"
        graph << [te_sid, TIME[time_property], time_description] if te_type != "TemporalEntity"
        graph << [time_description, RDF.type, TIME.DateTimeDescription]
        graph << [time_description, TIME.year, interaction.time_year] if interaction.time_year
        graph << [time_description, TIME.month, interaction.time_month] if interaction.time_month
        graph << [time_description, TIME.week, interaction.time_week] if interaction.time_week
        graph << [time_description, TIME.day, interaction.time_day] if interaction.time_day
        graph << [time_description, TIME.hour, interaction.time_hour] if interaction.time_hour
        graph << [time_description, TIME.minute, interaction.time_minute] if interaction.time_minute
        graph << [time_description, TIME.second, interaction.time_second] if interaction.time_second
      end
      if interaction.duration_description.present?
        duration_description = RDF::Node.new "#{interaction_sid}DurationDescription"
        graph << [te_sid, TIME.hasDurationDescription, duration_description]
        graph << [duration_description, RDF.type, TIME.DurationDescription]
        graph << [duration_description, TIME.years, interaction.duration_years] if interaction.duration_years
        graph << [duration_description, TIME.months, interaction.duration_months] if interaction.duration_months
        graph << [duration_description, TIME.days, interaction.duration_days] if interaction.duration_days
        graph << [duration_description, TIME.hours, interaction.duration_hours] if interaction.duration_hours
        graph << [duration_description, TIME.minutes, interaction.duration_minutes] if interaction.duration_minutes
        graph << [duration_description, TIME.seconds, interaction.duration_seconds] if interaction.duration_seconds
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
            priceSpecification = RDF::Node.new "#{resource_sid}PriceSpecification"
            graph << [resource_sid, LSS_USDL.hasPriceSpecification, priceSpecification]
            graph << [priceSpecification, RDF.type, GR.PriceSpecification]
            graph << [priceSpecification, GR.hasCurrencyValue, resource.value_] if resource.value
            graph << [priceSpecification, GR.hasMaxCurrencyValue, resource.max_value_] if resource.max_value
            graph << [priceSpecification, GR.hasMinCurrencyValue, resource.min_value_] if resource.min_value
            graph << [priceSpecification, GR.hasCurrency, resource.unit_of_measurement] if resource.unit_of_measurement.present?
          # Quantitative value
          else
            quantitativeValue = RDF::Node.new "#{resource_sid}QuantitativeValue"
            graph << [resource_sid, LSS_USDL.hasQuantitativeValue, quantitativeValue]
            graph << [quantitativeValue, RDF.type, GR.QuantitativeValue]
            graph << [quantitativeValue, GR.hasValue, resource.value_] if resource.value
            graph << [quantitativeValue, GR.hasMaxValue, resource.max_value_] if resource.max_value
            graph << [quantitativeValue, GR.hasMinValue, resource.min_value_] if resource.min_value
            graph << [quantitativeValue, GR.hasUnitOfMeasurement, resource.unit_of_measurement] if resource.unit_of_measurement.present?
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