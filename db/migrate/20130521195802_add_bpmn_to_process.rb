class AddBpmnToProcess < ActiveRecord::Migration
  def change
    add_column :process_entities, :bpmn_uri, :string
  end
end
