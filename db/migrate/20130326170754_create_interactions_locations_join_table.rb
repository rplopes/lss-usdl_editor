class CreateInteractionsLocationsJoinTable < ActiveRecord::Migration
  def up
    create_table :interactions_locations, :id => false do |t|
      t.integer :interaction_id
      t.integer :location_id
    end

    add_index :interactions_locations, [:interaction_id, :location_id]
  end

  def down
    drop_table :interactions_locations
  end
end
