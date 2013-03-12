class CreateServiceSystems < ActiveRecord::Migration
  def change
    create_table :service_systems do |t|
      t.string :uri
      t.string :prefix
      t.string :label
      t.text :comment

      t.timestamps
    end
  end
end
