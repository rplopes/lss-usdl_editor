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
    bpmn: 'http://www.scch.at/ontologies/bpmn20.owl#',
    dbpedia: 'http://dbpedia.org/resource/',
    usdl: 'http://www.linked-usdl.org/ns/usdl#',
    'lss-usdl' => ONTOLOGY_URL
  }

  RDFS = RDF::RDFS
  FOAF = RDF::FOAF
  GR   = RDF::Vocabulary.new 'http://purl.org/goodrelations/v1#'
  S    = RDF::Vocabulary.new 'http://schema.org/'
  GN   = RDF::Vocabulary.new 'http://sws.geonames.org/'
  TIME = RDF::Vocabulary.new 'http://www.w3.org/2006/time#'
  DBP  = RDF::Vocabulary.new 'http://dbpedia.org/resource/'

  USDL = RDF::Vocabulary.new 'http://www.linked-usdl.org/ns/usdl#'


  ##########################################
  #
  # Generic method that chooses between from_lss_usdl_to_db
  # and from_linked_usdl_to_db based on file's data
  #
  ##########################################
  def self.import_file(file, author)
    graph = RDF::Graph.load(file.tempfile.path)
    is_lss_usdl = false
    is_linked_usdl = false
    RDF::Query.new({q: {RDF.type  => LSS_USDL.ServiceSystem}}).execute(graph).each do |s|
      is_lss_usdl = true
    end
    RDF::Query.new({q: {RDF.type => USDL.Service}}).execute(graph).each do |s|
      is_linked_usdl = true
    end
    if is_lss_usdl and not is_linked_usdl
      from_lss_usdl_to_db(file, author)
    elsif not is_lss_usdl and is_linked_usdl
      from_linked_usdl_to_db(file, author)
    end
  end


  ##########################################
  #
  # Imports an LSS-USDL file into the database
  #
  ##########################################
  def self.from_lss_usdl_to_db(file, author)
    graph = RDF::Graph.load(file.tempfile.path)
    service_system = ServiceSystem.new
    begin
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
        o.bpmn_uri = query_str(graph, s.q, LSS_USDL.hasBPMN)
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
          o.resource_type = "#{subclass}Resource" if subclass.present?
          o.dbpedia_resource = query_str(graph, s.q, LSS_USDL.hasDBpediaResource)
          # Quantitative Value
          RDF::Query.new({s.q => {LSS_USDL.hasQuantitativeValue => :qv}}).execute(graph).each do |s2|
            o.value = query_num(graph, s2.qv, GR.hasValue)
            o.max_value = query_num(graph, s2.qv, GR.hasMaxValue)
            o.min_value = query_num(graph, s2.qv, GR.hasMinValue)
            o.unit_of_measurement = query_str(graph, s2.qv, GR.hasUnitOfMeasurement)
          end
          # Price Specification
          RDF::Query.new({s.q => {LSS_USDL.hasPriceSpecification => :ps}}).execute(graph).each do |s2|
            o.value = query_num(graph, s2.ps, GR.hasCurrencyValue)
            o.max_value = query_num(graph, s2.ps, GR.hasMaxCurrencyValue)
            o.min_value = query_num(graph, s2.ps, GR.hasMinCurrencyValue)
            o.unit_of_measurement = query_str(graph, s2.ps, GR.hasCurrency)
          end
          o.save
        end
      end

      # Interactions
      ([""] | Interaction.subclasses).each do |subclass|
        RDF::Query.new({q: {RDF.type => LSS_USDL["#{subclass}Interaction"]}}).execute(graph).each do |s|
          o = Interaction.new
          o.sid = s.q.to_s.gsub(/^.*#/, '')
          o.service_system = service_system
          o.label = query_str(graph, s.q, RDFS.label)
          o.comment = query_str(graph, s.q, RDFS.comment)
          o.interaction_type = "#{subclass}Interaction" if subclass.present?
          o.roles = Array(query_el(graph, s.q, LSS_USDL.isPerformedBy, service_system.id, Role))
          o.goals = Array(query_el(graph, s.q, LSS_USDL.hasGoal, service_system.id, Goal))
          o.processes = Array(query_el(graph, s.q, LSS_USDL.belongsToProcess, service_system.id, ProcessEntity))
          o.locations = Array(query_el(graph, s.q, LSS_USDL.hasLocation, service_system.id, Location))
          o.received_resources = Array(query_el(graph, s.q, LSS_USDL.receivesResource, service_system.id, Resource))
          o.created_resources = Array(query_el(graph, s.q, LSS_USDL.createsResource, service_system.id, Resource))
          o.consumed_resources = Array(query_el(graph, s.q, LSS_USDL.consumesResource, service_system.id, Resource))
          o.returned_resources = Array(query_el(graph, s.q, LSS_USDL.returnsResource, service_system.id, Resource))

          # Time
          RDF::Query.new({s.q => {LSS_USDL.hasTime => :time}, time: {LSS_USDL.hasTemporalEntity => :te}}).execute(graph).each do |s2|
            i_before = query_str(graph, s2.te, TIME.intervalBefore)
            i_during = query_str(graph, s2.te, TIME.intervalDuring)
            i_after = query_str(graph, s2.te, TIME.intervalAfter)
            if i_before
              before = Interaction.where("service_system_id = ? and sid = ?", service_system.id, i_before.gsub(/(^.*#)|(Time$)/, ''))
              o.interaction_after = before.first if before.present?
            end
            if i_during
              during = Interaction.where("service_system_id = ? and sid = ?", service_system.id, i_during.gsub(/(^.*#)|(Time$)/, ''))
              o.interaction_during = during.first if during.present?
            end
            if i_after
              after = Interaction.where("service_system_id = ? and sid = ?", service_system.id, i_after.gsub(/(^.*#)|(Time$)/, ''))
              o.interaction_before = after.first if after.present?
            end
            # DateTimeDescription
            RDF::Query.new({s2.te => {TIME.hasDateTimeDescription => :dtd}}).execute(graph).each do |s3|
              o.time_year = query_num(graph, s3.dtd, TIME.year)
              o.time_month = query_num(graph, s3.dtd, TIME.month)
              o.time_week = query_num(graph, s3.dtd, TIME.week)
              o.time_day = query_num(graph, s3.dtd, TIME.day)
              o.time_hour = query_num(graph, s3.dtd, TIME.hour)
              o.time_minute = query_num(graph, s3.dtd, TIME.minute)
              o.time_second = query_num(graph, s3.dtd, TIME.second)
            end
            # DurationDescription
            RDF::Query.new({s2.te => {TIME.hasDurationDescription => :dd}}).execute(graph).each do |s3|
              o.duration_years = query_num(graph, s3.dd, TIME.years)
              o.duration_months = query_num(graph, s3.dd, TIME.months)
              o.duration_days = query_num(graph, s3.dd, TIME.days)
              o.duration_hours = query_num(graph, s3.dd, TIME.hours)
              o.duration_minutes = query_num(graph, s3.dd, TIME.minutes)
              o.duration_seconds = query_num(graph, s3.dd, TIME.seconds)
            end
          end

          o.save
        end
      end

      return service_system
    rescue
      service_system.destroy
      return nil
    end
  end


  ##########################################
  #
  # Imports a Linked-USDL file into the database
  #
  ##########################################
  def self.from_linked_usdl_to_db(file, author)
    graph = RDF::Graph.load(file.tempfile.path)
    used_sids = []
    service_system = ServiceSystem.new
    begin
      service_system.user = author

      # Service System
      RDF::Query.new({q: {RDF.type => USDL.Service}}).execute(graph).each do |s|
        service_system.uri = s.q.to_s.gsub(/#.*/, '#')
        service_system.label = query_str(graph, s.q, RDFS.label)
        service_system.comment = query_str(graph, s.q, RDFS.comment)
        service_system.save!
      end

      # Roles
      RDF::Query.new({q: {USDL.hasInteractingEntity => :role}}).execute(graph).each do |s|
        unless used_sids.index(s.role)
          used_sids << s.role
          o = Role.new
          o.sid = s.role.to_s.gsub(/^.*#/, '')
          o.service_system = service_system
          RDF::Query.new({s.role => {RDF.type => :type}}).execute(graph).each do |s2|
            o.label = s2.type.gsub(/^.*#/, '') if s2.type != USDL.InteractingEntity
          end
          o.label = query_str(graph, s.role, RDFS.label) if o.label.blank?
          o.comment = query_str(graph, s.role, RDFS.comment)
          o.save
        end
      end

      # Resources
      RDF::Query.new({q: {RDF.type => RDF['Resource']}}).execute(graph).each do |s|
        unless used_sids.index(s.q)
          used_sids << s.q
          o = Resource.new
          o.sid = s.q.to_s.gsub(/^.*#/, '')
          o.service_system = service_system
          o.label = query_str(graph, s.q, RDFS.label)
          o.comment = query_str(graph, s.q, RDFS.comment)
          o.save
        end
      end

      # Interactions
      RDF::Query.new({q: {RDF.type => USDL.InteractionPoint}}).execute(graph).each do |s|
        unless used_sids.index(s.q)
          used_sids << s.q
          o = Interaction.new
          o.sid = s.q.to_s.gsub(/^.+#/, '')
          o.service_system = service_system
          o.label = query_str(graph, s.q, RDFS.label)
          o.comment = query_str(graph, s.q, RDFS.comment)
          o.interaction_type = "CustomerInteraction"
          o.roles = Array(query_el(graph, s.q, USDL.hasInteractingEntity, service_system.id, Role))
          o.received_resources = Array(query_el(graph, s.q, USDL.receives, service_system.id, Resource))
          o.returned_resources = Array(query_el(graph, s.q, USDL.yields, service_system.id, Resource))

          # Temporal entity
          RDF::Query.new({q: {USDL.spansInterval => :te}}).execute(graph).each do |s2|
            i_before = query_str(graph, s2.te, TIME.intervalBefore)
            i_during = query_str(graph, s2.te, TIME.intervalDuring)
            i_after = query_str(graph, s2.te, TIME.intervalAfter)
            if i_before
              before = Interaction.where("service_system_id = ? and sid = ?", service_system.id, i_before.gsub(/(^.*#)|(Time$)/, ''))
              o.interaction_after = before.first if before.present?
            end
            if i_during
              during = Interaction.where("service_system_id = ? and sid = ?", service_system.id, i_during.gsub(/(^.*#)|(Time$)/, ''))
              o.interaction_during = during.first if during.present?
            end
            if i_after
              after = Interaction.where("service_system_id = ? and sid = ?", service_system.id, i_after.gsub(/(^.*#)|(Time$)/, ''))
              o.interaction_before = after.first if after.present?
            end
            # DateTimeDescription
            RDF::Query.new({s2.te => {TIME.hasDateTimeDescription => :dtd}}).execute(graph).each do |s3|
              o.time_year = query_num(graph, s3.dtd, TIME.year)
              o.time_month = query_num(graph, s3.dtd, TIME.month)
              o.time_week = query_num(graph, s3.dtd, TIME.week)
              o.time_day = query_num(graph, s3.dtd, TIME.day)
              o.time_hour = query_num(graph, s3.dtd, TIME.hour)
              o.time_minute = query_num(graph, s3.dtd, TIME.minute)
              o.time_second = query_num(graph, s3.dtd, TIME.second)
            end
            # DurationDescription
            RDF::Query.new({s2.te => {TIME.hasDurationDescription => :dd}}).execute(graph).each do |s3|
              o.duration_years = query_num(graph, s3.dd, TIME.years)
              o.duration_months = query_num(graph, s3.dd, TIME.months)
              o.duration_days = query_num(graph, s3.dd, TIME.days)
              o.duration_hours = query_num(graph, s3.dd, TIME.hours)
              o.duration_minutes = query_num(graph, s3.dd, TIME.minutes)
              o.duration_seconds = query_num(graph, s3.dd, TIME.seconds)
            end
          end

          o.save
        end
      end

      return service_system
    rescue
      service_system.destroy
      return nil
    end
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
    service_sid = add_entity data, graph, LSS_USDL.ServiceSystem, service_system, sids

    # Interactions
    service_system.interactions.each do |interaction|
      interaction_type = interaction.interaction_type.present? ? interaction.interaction_type : 'Interaction'
      interaction_sid = add_entity data, graph, LSS_USDL[interaction_type], interaction, sids
      graph << [data[service_sid], LSS_USDL.hasInteraction, data[interaction.sid]]
    end

    service_system.interactions.each do |interaction|

      # Roles
      interaction.roles.each do |role|
        if used_entities.index(role)
          graph << [data[interaction.sid], LSS_USDL.isPerformedBy, data[role.sid]]
          next
        else
          role_id = add_entity data, graph, LSS_USDL.Role, role, sids
          used_entities << role
        end
        graph << [data[interaction.sid], LSS_USDL.isPerformedBy, data[role_id]]

        # Business entity
        if role.business_entity
          be = role.business_entity
          if used_entities.index(be)
            graph << [data[role_id], LSS_USDL.belongsToBusinessEntity, data[be.sid]]
            next
          else
            be.sid = camel_case(be.foaf_name)
            be.sid = "#{be.sid}#{Time.now.to_i}" if sids.index(be.sid)
            be.save
            sids << be.sid
            used_entities << be
          end
          graph << [data[role_id], LSS_USDL.belongsToBusinessEntity, data[be.sid]]
          graph << [data[be.sid], RDF.type, GR.BusinessEntity]
          graph << [data[be.sid], FOAF.name, be.foaf_name]
          graph << [data[be.sid], FOAF.page, be.foaf_page] if be.foaf_page.present?
          graph << [data[be.sid], FOAF.logo, be.foaf_logo] if be.foaf_logo.present?
          graph << [data[be.sid], S.telephone, be.s_telephone] if be.s_telephone.present?
          graph << [data[be.sid], S.email, be.s_email] if be.s_email.present?
          graph << [data[be.sid], GR.description, be.gr_description] if be.gr_description.present?
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
      # DateTimeDescription
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
      # DurationDescription
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
          goal_sid = add_entity data, graph, LSS_USDL.Goal, goal, sids
          used_entities << goal
        end
        graph << [data[interaction.sid], LSS_USDL.hasGoal, data[goal_sid]]
      end

      # Processes
      interaction.processes.each do |process|
        if used_entities.index(process)
          process_sid = process.sid
        else
          process_sid = add_entity data, graph, LSS_USDL.Process, process, sids
          used_entities << process
          graph << [data[process_sid], LSS_USDL.hasBPMN, process.bpmn_uri] if process.bpmn_uri.present?
        end
        graph << [data[interaction.sid], LSS_USDL.belongsToProcess, data[process_sid]]
      end

      # Locations
      interaction.locations.each do |location|
        if used_entities.index(location)
          graph << [data[interaction.sid], LSS_USDL.hasLocation, data[location.sid]]
          next
        else
          location_sid = add_entity data, graph, LSS_USDL.Location, location, sids
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
          new_location_sid = add_entity data, graph, LSS_USDL.Location, location, sids
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
          resource_sid = add_entity data, graph, LSS_USDL[resource_type], resource, sids
          used_entities << resource
          graph << [data[resource_sid], LSS_USDL.hasDBpediaResource, DBP[resource.dbpedia_resource.gsub(/.*\//, '')]] if resource.dbpedia_resource.present?
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


  ##########################################
  #
  # Exports from the database to a Linked-USDL file
  #
  ##########################################
  def self.from_db_to_linked_usdl(service_system)
    data = RDF::Vocabulary.new service_system.uri
    graph = RDF::Graph.new

    sids = []
    used_entities = []

    # Service system
    service_sid = add_entity data, graph, USDL.Service, service_system, sids

    # Interactions
    service_system.interactions.each do |interaction|
      next unless interaction.interaction_type == 'CustomerInteraction'
      interaction_sid = add_entity data, graph, USDL.InteractionPoint, interaction, sids
      graph << [data[service_sid], USDL.hasInteractionPoint, data[interaction.sid]]
      used_entities << interaction
    end

    service_system.interactions.each do |interaction|
      next unless interaction.interaction_type == 'CustomerInteraction'

      # Roles
      interaction.roles.each do |role|
        if used_entities.index(role)
          graph << [data[interaction.sid], USDL.hasInteractingEntity, data[role.sid]]
          next
        else
          ie_sid = add_entity data, graph, USDL.InteractingEntity, role, sids
          if ['Regulator', 'Producer', 'Provider', 'Intermediary', 'Consumer', 'Customer'].index(role.label)
            usdl_role = RDF::Node.new "#{ie_sid}BusinessRole"
            graph << [usdl_role, RDF.type, USDL[role.label]]
            graph << [data[ie_sid], USDL.hasEntityType, usdl_role]
          elsif ['Observer', 'Participant', 'Initiator', 'Mediator', 'Receiver'].index(role.label)
            usdl_role = RDF::Node.new "#{ie_sid}InteractionRole"
            graph << [usdl_role, RDF.type, USDL[role.label]]
            graph << [data[ie_sid], USDL.hasEntityType, usdl_role]
          end
          used_entities << role
          graph << [data[interaction.sid], USDL.hasInteractingEntity, data[role.sid]]
        end
      end

      # Resources
      (interaction.received_resources | interaction.returned_resources).each do |resource|
        unless used_entities.index(resource)
          resource_sid = add_entity data, graph, RDF['Resource'], resource, sids
          used_entities << resource
        end
        property = interaction.received_resources.index(resource) ? USDL.receives : USDL.yields
        graph << [data[interaction.sid], property, data[resource.sid]]
      end

      # Temporal entity
      te_sid = "#{interaction.sid.to_s.gsub(service_system.uri, '')}Time"
      te_type = interaction.time_description.present? ? "DateTimeInterval" : "ProperInterval"
      graph << [data[interaction.sid], USDL.spansInterval, data[te_sid]]
      graph << [data[te_sid], RDF.type, TIME[te_type]]
      # DateTimeDescription
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
      # DurationDescription
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
        graph << [data[te_sid], TIME.intervalAfter, data["#{i.sid}Time"]] if i and used_entities.index(i)
      end
      (interaction.interactions_during| [interaction.interaction_during]).each do |i|
        graph << [data[te_sid], TIME.intervalDuring, data["#{i.sid}Time"]] if i and used_entities.index(i)
      end
      (interaction.interactions_after | [interaction.interaction_after]).each do |i|
        graph << [data[te_sid], TIME.intervalBefore, data["#{i.sid}Time"]] if i and used_entities.index(i)
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
    els = []
    RDF::Query.new({element => {attribute => :attribute}}).execute(graph).each do |s|
      els << model.where("service_system_id = ? and sid = ?", service_system_id, s.attribute.to_s.gsub(/^.*#/, '')).first
    end
    if els.blank?
      return nil
    elsif els.size == 1
      return els.first
    else
      return els
    end
  end

  def self.add_entity(data, graph, type, entity, sids)
    sid = camel_case(entity.label)
    sid = "#{sid}#{Time.now.to_i}" if sids.index(sid)
    sids << sid
    if type != LSS_USDL['ServiceSystem'] and type != USDL['Service']
      entity.sid = sid
      entity.save
    end
    graph << [data[sid], RDF.type, type]
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