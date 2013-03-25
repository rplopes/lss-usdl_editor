class AddChronologicalOrderToInteration < ActiveRecord::Migration
  def change
    add_column :interactions, :before_interaction_id, :integer
    add_column :interactions, :during_interaction_id, :integer
    add_column :interactions, :after_interaction_id, :integer
  end
end
