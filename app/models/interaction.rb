class Interaction < ActiveRecord::Base
  attr_accessible :comment, :interaction_type, :label, :service_system_id, :sid
  belongs_to :service_system

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
