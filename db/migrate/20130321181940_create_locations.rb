class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :sid
      t.integer :service_system_id
      t.string :label
      t.integer :location_id
      t.string :gn_feature
      t.text :comment

      t.timestamps
    end
  end
end
