class AddTimeDescriptionToInteractions < ActiveRecord::Migration
  def change
    add_column :interactions, :time_day, :integer
    add_column :interactions, :time_hour, :integer
    add_column :interactions, :time_minute, :integer
    add_column :interactions, :time_month, :integer
    add_column :interactions, :time_second, :integer
    add_column :interactions, :time_week, :integer
    add_column :interactions, :time_year, :integer

    add_column :interactions, :duration_days, :integer
    add_column :interactions, :duration_hours, :integer
    add_column :interactions, :duration_minutes, :integer
    add_column :interactions, :duration_months, :integer
    add_column :interactions, :duration_seconds, :integer
    add_column :interactions, :duration_weeks, :integer
    add_column :interactions, :duration_years, :integer

    add_column :interactions, :temporal_entity_type, :string
  end
end
