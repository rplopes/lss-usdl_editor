class CreateInteractions < ActiveRecord::Migration
  def change
    create_table :interactions do |t|
      t.string :sid
      t.integer :service_system_id
      t.string :interaction_type
      t.string :label
      t.text :comment

      t.timestamps
    end
  end
end
