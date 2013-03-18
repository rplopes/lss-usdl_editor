class CreateBusinessEntities < ActiveRecord::Migration
  def change
    create_table :business_entities do |t|
      t.string :sid
      t.integer :service_system_id
      t.string :foaf_name
      t.string :foaf_page
      t.string :foaf_logo
      t.string :s_telephone
      t.string :s_email
      t.text :gr_description

      t.timestamps
    end
  end
end
