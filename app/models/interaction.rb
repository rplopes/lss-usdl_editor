class Interaction < ActiveRecord::Base
  attr_accessible :comment, :interaction_type, :label, :service_system_id, :sid,
                  :after_interaction_id, :during_interaction_id, :before_interaction_id
  belongs_to :service_system

  # These belongs_to names are inverted because if a has before_interaction_id B, then B is interaction_after A
  belongs_to :interaction_after, class_name: "Interaction", foreign_key: "before_interaction_id"
  belongs_to :interaction_during, class_name: "Interaction", foreign_key: "during_interaction_id"
  belongs_to :interaction_before, class_name: "Interaction", foreign_key: "after_interaction_id"

  has_many :interactions_before, class_name: "Interaction", foreign_key: "before_interaction_id"
  has_many :interactions_during, class_name: "Interaction", foreign_key: "during_interaction_id"
  has_many :interactions_after, class_name: "Interaction", foreign_key: "after_interaction_id"

  def self.subclasses
    ["Customer", "Onstage", "Backstage", "Support"]
  end

  def self.build_interactions_blueprint(ss_id)
    interactions = Interaction.where "service_system_id = ?", ss_id
    blueprint = Array.new(4) { Array.new }
    puts ss_id
    puts Interaction.where "service_system_id = ?", ss_id
    return blueprint if interactions.blank?

    cols = build_blueprint_cols(interactions)
    cols = sort_blueprint_cols(cols)

    cols.each do |col|
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

      puts interactions
      interaction = interactions.shift # remove this interaction from staged interactions
      area_of_action = interaction.interaction_type.gsub /Interaction/, ""

      # Create blueprint column and append this interaction
      col = Array.new(4)
      col[subclasses.index(area_of_action)] = interaction

      # Append to this column the interaction marked as happening at the same time
      if interaction.interaction_during.present?
        during = interaction.interaction_during
        during_aoa = during.interaction_type.gsub /Interaction/, ""
        col[subclasses.index(during_aoa)] = during
        interactions.delete_at(interactions.index(during)) # remove this interaction from staged interactions
      end

      # Append to this column all other interactions happening at the same time
      interaction.interactions_during.each do |during|
        if interactions.index(during) # only add those that haven't been added yet
          during_aoa = during.interaction_type.gsub /Interaction/, ""
          col[subclasses.index(during_aoa)] = during
          puts interactions.size
          interactions.delete_at(interactions.index(during)) # remove this interaction from staged interactions
          puts interactions.size
        end
      end

      cols.append col

    end while interactions.present?

    return cols
  end

  def self.sort_blueprint_cols(cols)
    return cols # TODO: sort
  end

end
