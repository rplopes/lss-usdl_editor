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

    return cols
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

    # First searching based on curren't information
    current.each do |interaction|
      if interaction and interaction.interaction_before
        cols.each do |col|
          return rewind_cols(cols, col) if col.index(interaction.interaction_before)
        end
      end
    end

    # If nothing was found, search based on other's information
    current.each do |interaction|
      if interaction
        interaction.interactions_before.each do |interaction_before|
          cols.each do |col|
            return rewind_cols(cols, col) if col.index(interaction_before)
          end
        end
      end
    end

    # If nothing was found, then this is the earliest column
    return current
  end

  def self.forward_col(cols, current)

    # First searching based on curren't information
    current.each do |interaction|
      if interaction and interaction.interaction_after
        cols.each do |col|
          return col if col.index(interaction.interaction_after)
        end
      end
    end

    # If nothing was found, search based on other's information
    current.each do |interaction|
      if interaction
        interaction.interactions_after.each do |interaction_after|
          cols.each do |col|
            return col if col.index(interaction_after)
          end
        end
      end
    end

    # If nothing was found, then this is the last column and we can't forward more
    return nil
  end

end
