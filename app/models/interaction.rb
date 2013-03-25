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
    [ "Customer", "Onstage", "Backstage", "Support" ].map { |sc| ["#{sc} interaction", "#{sc}Interaction"] }
  end

  def self.build_interactions_blueprint(ss_id)
    interactions = Interaction.where "service_system_id = ?", ss_id
    blueprint = Array.new(4) { Array.new }

    interactions.each do |interaction|
      (0..3).each do |i|
        if interaction.interaction_type == subclasses[i][1]
          blueprint[i].append interaction
        else
          blueprint[i].append nil
        end
      end
    end

    return blueprint
  end
end
