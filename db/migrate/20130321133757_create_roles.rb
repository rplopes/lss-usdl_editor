class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :sid
      t.integer :service_system_id
      t.integer :business_entity_id
      t.string :label
      t.text :comment

      t.timestamps
    end
  end
end
