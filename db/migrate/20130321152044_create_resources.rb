class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.string :sid
      t.integer :service_system_id
      t.string :label
      t.float :value
      t.float :max_value
      t.float :min_value
      t.string :unit_of_measurement
      t.string :resource_type
      t.text :comment

      t.timestamps
    end
  end
end
