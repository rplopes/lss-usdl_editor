class Interaction < ActiveRecord::Base
  attr_accessible :comment, :interaction_type, :label, :service_system_id, :sid,
                  :after_interaction_id, :during_interaction_id, :before_interaction_id,
                  :temporal_entity_type, :time_hour, :time_minute, :time_second, :time_day,
                  :time_month, :time_year, :time_week, :duration_years, :duration_months,
                  :duration_days, :duration_hours, :duration_minutes, :duration_seconds
  belongs_to :service_system

  # These belongs_to names are inverted because if a has before_interaction_id B, then B is interaction_after A
  belongs_to :interaction_after, class_name: "Interaction", foreign_key: "before_interaction_id"
  belongs_to :interaction_during, class_name: "Interaction", foreign_key: "during_interaction_id"
  belongs_to :interaction_before, class_name: "Interaction", foreign_key: "after_interaction_id"

  has_many :interactions_before, class_name: "Interaction", foreign_key: "before_interaction_id"
  has_many :interactions_during, class_name: "Interaction", foreign_key: "during_interaction_id"
  has_many :interactions_after, class_name: "Interaction", foreign_key: "after_interaction_id"

  # Connections to the other elements
  has_and_belongs_to_many :roles
  has_and_belongs_to_many :goals
  has_and_belongs_to_many :locations
  has_and_belongs_to_many :processes, class_name: "ProcessEntity", join_table: "interactions_processes"
  has_and_belongs_to_many :received_resources, class_name: "Resource", join_table: "interactions_receives_resources"
  has_and_belongs_to_many :created_resources, class_name: "Resource", join_table: "interactions_creates_resources"
  has_and_belongs_to_many :consumed_resources, class_name: "Resource", join_table: "interactions_consumes_resources"
  has_and_belongs_to_many :returned_resources, class_name: "Resource", join_table: "interactions_returns_resources"

  validates :label, :sid, presence: true
  validates :after_interaction_id, numericality: { only_integer: true }, allow_nil: true
  validates :during_interaction_id, numericality: { only_integer: true }, allow_nil: true
  validates :before_interaction_id, numericality: { only_integer: true }, allow_nil: true

  validates :time_hour, numericality: { only_integer: true }, allow_nil: true
  validates :time_minute, numericality: { only_integer: true }, allow_nil: true
  validates :time_second, numericality: { only_integer: true }, allow_nil: true
  validates :time_day, numericality: { only_integer: true }, allow_nil: true
  validates :time_month, numericality: { only_integer: true }, allow_nil: true
  validates :time_year, numericality: { only_integer: true }, allow_nil: true
  validates :time_week, numericality: { only_integer: true }, allow_nil: true

  validates :duration_hours, numericality: { only_integer: true }, allow_nil: true
  validates :duration_minutes, numericality: { only_integer: true }, allow_nil: true
  validates :duration_seconds, numericality: { only_integer: true }, allow_nil: true
  validates :duration_days, numericality: { only_integer: true }, allow_nil: true
  validates :duration_months, numericality: { only_integer: true }, allow_nil: true
  validates :duration_years, numericality: { only_integer: true }, allow_nil: true

  validates :service_system_id, numericality: { only_integer: true }

  def resources
    received_resources | created_resources | consumed_resources | returned_resources
  end

  def self.subclasses
    ["Customer", "Onstage", "Backstage", "Support"]
  end

  def self.temporal_entity_subclasses
    ["Interval", "Instant"]
  end

  def time_description
    desc = ""
    desc += "Year #{self.time_year} " if self.time_year
    desc += "month #{self.time_month} " if self.time_month
    desc += "week #{self.time_week} " if self.time_week
    desc += "day #{self.time_day} " if self.time_day
    desc += "#{self.time_hour} hours " if self.time_hour
    desc += "#{self.time_minute} minutes " if self.time_minute
    desc += "#{self.time_second} seconds" if self.time_second
    return desc.capitalize.strip
  end

  def duration_description
    desc = ""
    desc += "#{self.duration_seconds} seconds " if self.duration_seconds
    desc += "#{self.duration_minutes} minutes " if self.duration_minutes
    desc += "#{self.duration_hours} hours " if self.duration_hours
    desc += "#{self.duration_days} days " if self.duration_days
    desc += "#{self.duration_months} months " if self.duration_months
    desc += "#{self.duration_years} years" if self.duration_years
    return desc.strip
  end

  def self.build_interactions_blueprint(ss_id)
    interactions = Interaction.where "service_system_id = ?", ss_id
    blueprint = Array.new(4) { Array.new }
    return blueprint if interactions.blank?

    build_blueprint_cols(interactions).each do |col|
      (0..3).each do |i|
        blueprint[i].append col[i]
      end
    end

    return blueprint
  end

  private

  def self.build_blueprint_cols(interactions)
    cols = []

    begin
      # Create blueprint column and append this interaction
      col = Array.new(4)
      interaction = interactions.shift # remove this interaction from staged interactions
      col[subclasses.index(interaction.interaction_type.gsub(/Interaction/, ""))] = interaction

      # Append to this column the interaction marked as happening at the same time
      if interaction.interaction_during.present?
        col[subclasses.index(interaction.interaction_during.interaction_type.gsub(/Interaction/, ""))] = interaction.interaction_during
        interactions.delete_at(interactions.index(interaction.interaction_during)) # remove this interaction from staged interactions
      end

      # Append to this column all other interactions happening at the same time
      interaction.interactions_during.each do |during|
        if interactions.index(during) # only add those that haven't been added yet
          col[subclasses.index(during.interaction_type.gsub(/Interaction/, ""))] = during
          interactions.delete_at(interactions.index(during)) # remove this interaction from staged interactions
        end
      end

      cols.append col
    end while interactions.present?

    return sort_blueprint_cols(cols)
  end

  def self.sort_blueprint_cols(cols)
    new_cols = []

    begin
      col = rewind_cols(cols, cols.first) # Get a column with no previous interactions
      new_cols.append col
      cols.delete_at(cols.index(col))
      next_col = forward_col(cols, col) # Get the next column to move it to the begining of the cols array
      if next_col 
        cols.delete_at(cols.index(next_col))
        cols.unshift next_col
      end
    end while cols.present?

    return new_cols
  end

  def self.rewind_cols(cols, current)
    current.each do |interaction|
      if interaction
        cols.each do |col|
          # Search based on current's information
          return rewind_cols(cols, col) if interaction.interaction_before and col.index(interaction.interaction_before)
          # Search based on other's information
          interaction.interactions_before.each do |interaction_before|
            return rewind_cols(cols, col) if col.index(interaction_before)
          end
        end
      end
    end
    return current # If nothing was found, then this is the earliest column
  end

  def self.forward_col(cols, current)
    current.each do |interaction|
      if interaction
        cols.each do |col|
          # Search based on current's information
          return col if interaction.interaction_after and col.index(interaction.interaction_after)
          # Search based on other's information
          interaction.interactions_after.each do |interaction_after|
            return col if col.index(interaction_after)
          end
        end
      end
    end
    return nil # If nothing was found, then we had the last column and we can't forward more
  end

end
