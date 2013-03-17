class CreateProcessEntities < ActiveRecord::Migration
  def change
    create_table :process_entities do |t|
      t.string :sid
      t.integer :service_system_id
      t.string :label
      t.text :comment

      t.timestamps
    end
  end
end
