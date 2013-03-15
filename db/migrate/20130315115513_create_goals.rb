class CreateGoals < ActiveRecord::Migration
  def change
    create_table :goals do |t|
      t.string :sid
      t.integer :service_system_id
      t.string :label
      t.text :comment

      t.timestamps
    end
  end
end
