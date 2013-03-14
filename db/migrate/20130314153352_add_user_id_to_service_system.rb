class AddUserIdToServiceSystem < ActiveRecord::Migration
  def change
    add_column :service_systems, :user_id, :integer
    add_index :service_systems, :user_id
  end
end
