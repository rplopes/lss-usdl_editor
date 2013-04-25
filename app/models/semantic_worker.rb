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


  ##########################################
  #
  # Imports an LSS-USDL file into the database
  #
  ##########################################
  def self.from_lss_usdl_to_db(file, author)
    graph = RDF::Graph.load(file.tempfile.path)
    service_system = ServiceSystem.new
    service_system.user = author

    # Service System
    RDF::Query.new({q: {RDF.type  => LSS_USDL.ServiceSystem}}).execute(graph).each do |s|
      service_system.uri = s.q.to_s.gsub(/#.*/, '#')
      service_system.label = query_str(graph, s.q, RDFS.label)
      service_system.comment = query_str(graph, s.q, RDFS.comment)
      service_system.save!
      puts service_system.inspect
    end

    # Business Entities
    RDF::Query.new({q: {RDF.type => GR.BusinessEntity}}).execute(graph).each do |s|
      o = BusinessEntity.new
      o.sid = s.q.to_s.gsub(/^.*#/, '')
      o.service_system = service_system
      o.foaf_name = query_str(graph, s.q, FOAF.name)
      o.foaf_page = query_str(graph, s.q, FOAF.page)
      o.foaf_logo = query_str(graph, s.q, FOAF.logo)
      o.s_email = query_str(graph, s.q, S.email)
      o.s_telephone = query_str(graph, s.q, S.telephone)
      o.gr_description = query_str(graph, s.q, GR.description)
      o.save
    end

    # Roles
    RDF::Query.new({q: {RDF.type => LSS_USDL.Role}}).execute(graph).each do |s|
      o = Role.new
      o.sid = s.q.to_s.gsub(/^.*#/, '')
      o.service_system = service_system
      o.label = query_str(graph, s.q, RDFS.label)
      o.comment = query_str(graph, s.q, RDFS.comment)
      o.business_entity = query_el(graph, s.q, LSS_USDL.belongsToBusinessEntity, service_system.id, BusinessEntity)
      o.save
    end

    # Goals
    RDF::Query.new({q: {RDF.type => LSS_USDL.Goal}}).execute(graph).each do |s|
      o = Goal.new
      o.sid = s.q.to_s.gsub(/^.*#/, '')
      o.service_system = service_system
      o.label = query_str(graph, s.q, RDFS.label)
      o.comment = query_str(graph, s.q, RDFS.comment)
      o.save
    end

    # Processes
    RDF::Query.new({q: {RDF.type => LSS_USDL.Process}}).execute(graph).each do |s|
      o = ProcessEntity.new
      o.sid = s.q.to_s.gsub(/^.*#/, '')
      o.service_system = service_system
      o.label = query_str(graph, s.q, RDFS.label)
      o.comment = query_str(graph, s.q, RDFS.comment)
      o.save
    end

    # Locations
    RDF::Query.new({q: {RDF.type => LSS_USDL.Location}}).execute(graph).each do |s|
      o = Location.new
      o.sid = s.q.to_s.gsub(/^.*#/, '')
      o.service_system = service_system
      o.label = query_str(graph, s.q, RDFS.label)
      o.comment = query_str(graph, s.q, RDFS.comment)
      o.gn_feature = query_str(graph, s.q, LSS_USDL.isLocationFrom)
      o.save
    end
    RDF::Query.new({q: {RDF.type => LSS_USDL.Location}}).execute(graph).each do |s|
      o = Location.where("service_system_id = ? and sid = ?", service_system.id, s.q.to_s.gsub(/^.*#/, '')).first
      o.broader_location = query_el(graph, s.q, LSS_USDL.isLocatedIn, service_system.id, Location)
      o.save
    end

    # Resources
    ([""] | Resource.subclasses).each do |subclass|
      RDF::Query.new({q: {RDF.type => LSS_USDL["#{subclass}Resource"]}}).execute(graph).each do |s|
        o = Resource.new
        o.sid = s.q.to_s.gsub(/^.*#/, '')
        o.service_system = service_system
        o.label = query_str(graph, s.q, RDFS.label)
        o.comment = query_str(graph, s.q, RDFS.comment)
        o.resource_type = "#{subclass}Resource"
        # Quantitative Value
        RDF::Query.new({q2: {LSS_USDL.hasQuantitativeValue => :qv}}).execute(graph).each do |s2|
          if s.q == s2.q2
            o.value = query_num(graph, s2.qv, GR.hasValue)
            o.max_value = query_num(graph, s2.qv, GR.hasMaxValue)
            o.min_value = query_num(graph, s2.qv, GR.hasMinValue)
            o.unit_of_measurement = query_str(graph, s2.qv, GR.hasUnitOfMeasurement)
          end
        end
        # Proce Specification
        RDF::Query.new({q2: {LSS_USDL.hasPriceSpecification => :ps}}).execute(graph).each do |s2|
          if s.q == s2.q2
            o.value = query_num(graph, s2.ps, GR.hasCurrencyValue)
            o.max_value = query_num(graph, s2.ps, GR.hasMaxCurrencyValue)
            o.min_value = query_num(graph, s2.ps, GR.hasMinCurrencyValue)
            o.unit_of_measurement = query_str(graph, s2.ps, GR.hasCurrency)
          end
        end
        o.save
      end
    end

    return service_system
  end


  ##########################################
  #
  # Exports from the database to an LSS-USDL file
  #
  ##########################################
  def self.from_db_to_lss_usdl(service_system)
    data = RDF::Vocabulary.new service_system.uri
    graph = RDF::Graph.new

    sids = []
    used_entities = []

    # Service system
    service_sid = add_entity data, graph, 'ServiceSystem', service_system, sids

    service_system.interactions.each do |interaction|

      # Interactions
      interaction_type = interaction.interaction_type.present? ? interaction.interaction_type : 'Interaction'
      interaction_sid = add_entity data, graph, interaction_type, interaction, sids
    end
    service_system.interactions.each do |interaction|
      graph << [data[service_sid], LSS_USDL.hasInteraction, data[interaction.sid]]

      # Roles
      interaction.roles.each do |role|
        if used_entities.index(role)
          graph << [data[interaction.sid], LSS_USDL.isPerformedBy, data[role.sid]]
          next
        else
          role_id = add_entity data, graph, 'Role', role, sids
          used_entities << role
        end
        graph << [data[interaction.sid], LSS_USDL.isPerformedBy, data[role_id]]

        # Business entity
        if role.business_entity
          if used_entities.index(role.business_entity)
            graph << [data[role_id], LSS_USDL.belongsToBusinessEntity, data[role.business_entity.sid]]
            next
          else
            business_entity_id = camel_case(role.business_entity.foaf_name)
            business_entity_id = "#{business_entity_id}#{Time.now.to_i}" if sids.index(business_entity_id)
            sids << business_entity_id
            used_entities << role.business_entity
          end
          graph << [data[role_id], LSS_USDL.belongsToBusinessEntity, data[business_entity_id]]
          graph << [data[business_entity_id], RDF.type, GR.BusinessEntity]
          graph << [data[business_entity_id], FOAF.name, role.business_entity.foaf_name]
          graph << [data[business_entity_id], FOAF.page, role.business_entity.foaf_page] if role.business_entity.foaf_page.present?
          graph << [data[business_entity_id], FOAF.logo, role.business_entity.foaf_logo] if role.business_entity.foaf_logo.present?
          graph << [data[business_entity_id], S.telephone, role.business_entity.s_telephone] if role.business_entity.s_telephone.present?
          graph << [data[business_entity_id], S.email, role.business_entity.s_email] if role.business_entity.s_email.present?
          graph << [data[business_entity_id], GR.description, role.business_entity.gr_description] if role.business_entity.gr_description.present?
        end
      end

      # Time
      time = RDF::Node.new "#{interaction.sid}Time"
      graph << [data[interaction.sid], LSS_USDL.hasTime, time]
      graph << [time, RDF.type, LSS_USDL.Time]
      # Temporal entity
      te_sid = "#{interaction.sid.to_s.gsub(service_system.uri, '')}Time"
      te_type = interaction.time_description.present? ? "DateTimeInterval" : "ProperInterval"
      graph << [time, LSS_USDL.hasTemporalEntity, data[te_sid]]
      graph << [data[te_sid], RDF.type, TIME[te_type]]
      if interaction.time_description.present?
        time_description = RDF::Node.new "#{interaction.sid}DateTimeDescription"
        graph << [data[te_sid], TIME.hasDateTimeDescription, time_description]
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
        duration_description = RDF::Node.new "#{interaction.sid}DurationDescription"
        graph << [data[te_sid], TIME.hasDurationDescription, duration_description]
        graph << [duration_description, RDF.type, TIME.DurationDescription]
        graph << [duration_description, TIME.years, interaction.duration_years] if interaction.duration_years
        graph << [duration_description, TIME.months, interaction.duration_months] if interaction.duration_months
        graph << [duration_description, TIME.days, interaction.duration_days] if interaction.duration_days
        graph << [duration_description, TIME.hours, interaction.duration_hours] if interaction.duration_hours
        graph << [duration_description, TIME.minutes, interaction.duration_minutes] if interaction.duration_minutes
        graph << [duration_description, TIME.seconds, interaction.duration_seconds] if interaction.duration_seconds
      end
      # Interactions flow
      (interaction.interactions_before | [interaction.interaction_before]).each do |i|
        graph << [data[te_sid], TIME.intervalAfter, data["#{i.sid}Time"]] if i
      end
      (interaction.interactions_during| [interaction.interaction_during]).each do |i|
        graph << [data[te_sid], TIME.intervalDuring, data["#{i.sid}Time"]] if i
      end
      (interaction.interactions_after | [interaction.interaction_after]).each do |i|
        graph << [data[te_sid], TIME.intervalBefore, data["#{i.sid}Time"]] if i
      end

      # Goals
      interaction.goals.each do |goal|
        if used_entities.index(goal)
          goal_sid = goal.sid
        else
          goal_sid = add_entity data, graph, 'Goal', goal, sids
          used_entities << goal
        end
        graph << [data[interaction.sid], LSS_USDL.hasGoal, data[goal_sid]]
      end

      # Processes
      interaction.processes.each do |process|
        if used_entities.index(process)
          process_sid = process.sid
        else
          process_sid = add_entity data, graph, 'Process', process, sids
          used_entities << process
        end
        graph << [data[interaction.sid], LSS_USDL.belongsToProcess, data[process_sid]]
      end

      # Locations
      interaction.locations.each do |location|
        if used_entities.index(location)
          graph << [data[interaction.sid], LSS_USDL.hasLocation, data[location.sid]]
          next
        else
          location_sid = add_entity data, graph, 'Location', location, sids
          used_entities << location
        end
        graph << [data[interaction.sid], LSS_USDL.hasLocation, data[location_sid]]
        graph << [data[location_sid], LSS_USDL.isLocationFrom, GN[location.gn_feature.gsub(/[^0-9]*/, '')]] if location.gn_feature.present?
        while location.location_id
          location = location.broader_location
          if used_entities.index(location)
            graph << [data[location_sid], LSS_USDL.isLocatedIn, data[location.sid]]
            break
          else
            used_entities << location
          end
          new_location_sid = add_entity data, graph, 'Location', location, sids
          graph << [data[new_location_sid], LSS_USDL.isLocationFrom, GN[location.gn_feature.gsub(/[^0-9]*/, '')]] if location.gn_feature.present?
          graph << [data[location_sid], LSS_USDL.isLocatedIn, data[new_location_sid]]
          location_sid = new_location_sid
        end
      end

      # Resources
      interaction.resources.each do |resource|
        old_resource = false
        resource_type = resource.resource_type.present? ? resource.resource_type : 'Resource'
        if used_entities.index(resource)
          resource_sid = resource.sid
          old_resource = true
        else
          resource_sid = add_entity data, graph, resource_type, resource, sids
          used_entities << resource
        end
        if interaction.received_resources.index(resource)
          resource_connection = 'receivesResource'
        elsif interaction.created_resources.index(resource)
          resource_connection = 'createsResource'
        elsif interaction.consumed_resources.index(resource)
          resource_connection = 'consumesResource'
        elsif interaction.returned_resources.index(resource)
          resource_connection = 'returnsResource'
        end
        graph << [data[interaction.sid], LSS_USDL[resource_connection], data[resource_sid]]
        next if old_resource

        if resource.value or resource.max_value or resource.min_value or resource.unit_of_measurement.present?
          # Price specification
          if resource_type == 'FinancialResource'
            priceSpecification = RDF::Node.new "#{resource_sid}PriceSpecification"
            graph << [data[resource_sid], LSS_USDL.hasPriceSpecification, priceSpecification]
            graph << [priceSpecification, RDF.type, GR.PriceSpecification]
            graph << [priceSpecification, GR.hasCurrencyValue, resource.value_] if resource.value
            graph << [priceSpecification, GR.hasMaxCurrencyValue, resource.max_value_] if resource.max_value
            graph << [priceSpecification, GR.hasMinCurrencyValue, resource.min_value_] if resource.min_value
            graph << [priceSpecification, GR.hasCurrency, resource.unit_of_measurement] if resource.unit_of_measurement.present?
          # Quantitative value
          else
            quantitativeValue = RDF::Node.new "#{resource_sid}QuantitativeValue"
            puts "#{resource_sid}QuantitativeValue"
            graph << [data[resource_sid], LSS_USDL.hasQuantitativeValue, quantitativeValue]
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

  def self.query_str(graph, element, attribute)
    RDF::Query.new({q: {attribute => :attribute}}).execute(graph).each do |s|
      return s.attribute.to_s if element == s.q
    end
    return nil
  end

  def self.query_num(graph, element, attribute)
    RDF::Query.new({q: {attribute => :attribute}}).execute(graph).each do |s|
      return s.attribute if element == s.q
    end
    return nil
  end

  def self.query_el(graph, element, attribute, service_system_id, model)
    RDF::Query.new({q: {attribute => :attribute}}).execute(graph).each do |s|
      if element == s.q
        return model.where("service_system_id = ? and sid = ?", service_system_id, s.attribute.to_s.gsub(/^.*#/, '')).first
      end
    end
    return nil
  end

  def self.add_entity(data, graph, type, entity, sids)
    sid = camel_case(entity.label)
    sid = "#{sid}#{Time.now.to_i}" if sids.index(sid)
    sids << sid
    if type != 'ServiceSystem'
      entity.sid = sid
      entity.save
    end
    graph << [data[sid], RDF.type, LSS_USDL[type]]
    graph << [data[sid], RDFS.label, entity.label]
    graph << [data[sid], RDFS.comment, entity.comment] if entity.comment.present?
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