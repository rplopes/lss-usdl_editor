class CreateInteractionsGoalsJoinTable < ActiveRecord::Migration
  def up
    create_table :goals_interactions, :id => false do |t|
      t.integer :interaction_id
      t.integer :goal_id
    end

    add_index :goals_interactions, [:interaction_id, :goal_id]
  end

  def down
    drop_table :goals_interactions
  end
end
