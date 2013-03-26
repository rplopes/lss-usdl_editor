class CreateInteractionsProcessesJoinTable < ActiveRecord::Migration
  def up
    create_table :interactions_processes, :id => false do |t|
      t.integer :interaction_id
      t.integer :process_entity_id
    end

    #add_index :interactions_processes, [:interaction_id, :process_entity_id]
  end

  def down
    drop_table :interactions_processes
  end
end
