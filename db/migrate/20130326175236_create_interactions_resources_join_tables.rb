class CreateInteractionsResourcesJoinTables < ActiveRecord::Migration
  def up
    create_table :interactions_receives_resources, :id => false do |t|
      t.integer :interaction_id
      t.integer :resource_id
    end
    create_table :interactions_creates_resources, :id => false do |t|
      t.integer :interaction_id
      t.integer :resource_id
    end
    create_table :interactions_consumes_resources, :id => false do |t|
      t.integer :interaction_id
      t.integer :resource_id
    end
    create_table :interactions_returns_resources, :id => false do |t|
      t.integer :interaction_id
      t.integer :resource_id
    end

    #add_index :interactions_receives_resources, [:interaction_id, :resource_id]
    #add_index :interactions_creates_resources, [:interaction_id, :resource_id]
    #add_index :interactions_consumes_resources, [:interaction_id, :resource_id]
    #add_index :interactions_returns_resources, [:interaction_id, :resource_id]
  end

  def down
    drop_table :interactions_receives_resources
    drop_table :interactions_creates_resources
    drop_table :interactions_consumes_resources
    drop_table :interactions_returns_resources
  end
end
