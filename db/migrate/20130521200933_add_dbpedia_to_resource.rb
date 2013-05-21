class AddDbpediaToResource < ActiveRecord::Migration
  def change
    add_column :resources, :dbpedia_resource, :string
  end
end
