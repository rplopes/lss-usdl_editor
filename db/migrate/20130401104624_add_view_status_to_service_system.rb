class AddViewStatusToServiceSystem < ActiveRecord::Migration
  def change
    add_column :service_systems, :view_status, :string
  end
end
