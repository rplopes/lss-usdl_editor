class Interaction < ActiveRecord::Base
  attr_accessible :comment, :interaction_type, :label, :service_system_id, :sid
  belongs_to :service_system

  def self.subclasses
    [ "Customer", "Onstage", "Backstage", "Support" ].map { |sc| ["#{sc} interaction", "#{sc}Interaction"] }
  end

  def self.build_interactions_blueprint(ss_id)
    interactions = []
    Interaction.subclasses.each do |subclass|
      interactions.append Interaction.where "service_system_id = ? and interaction_type = ?", ss_id, subclass[1]
    end
    return interactions
  end
end
