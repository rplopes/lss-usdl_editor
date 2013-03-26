class CreateInteractionsRolesJoinTable < ActiveRecord::Migration
  def up
    create_table :interactions_roles, :id => false do |t|
      t.integer :interaction_id
      t.integer :role_id
    end

    add_index :interactions_roles, [:interaction_id, :role_id]
  end

  def down
    drop_table :interactions_roles
  end
end
