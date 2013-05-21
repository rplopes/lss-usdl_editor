# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130521200933) do

  create_table "business_entities", :force => true do |t|
    t.string   "sid"
    t.integer  "service_system_id"
    t.string   "foaf_name"
    t.string   "foaf_page"
    t.string   "foaf_logo"
    t.string   "s_telephone"
    t.string   "s_email"
    t.text     "gr_description"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "goals", :force => true do |t|
    t.string   "sid"
    t.integer  "service_system_id"
    t.string   "label"
    t.text     "comment"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "goals_interactions", :id => false, :force => true do |t|
    t.integer "interaction_id"
    t.integer "goal_id"
  end

  add_index "goals_interactions", ["interaction_id", "goal_id"], :name => "index_goals_interactions_on_interaction_id_and_goal_id"

  create_table "interactions", :force => true do |t|
    t.string   "sid"
    t.integer  "service_system_id"
    t.string   "interaction_type"
    t.string   "label"
    t.text     "comment"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.integer  "before_interaction_id"
    t.integer  "during_interaction_id"
    t.integer  "after_interaction_id"
    t.integer  "time_day"
    t.integer  "time_hour"
    t.integer  "time_minute"
    t.integer  "time_month"
    t.integer  "time_second"
    t.integer  "time_week"
    t.integer  "time_year"
    t.integer  "duration_days"
    t.integer  "duration_hours"
    t.integer  "duration_minutes"
    t.integer  "duration_months"
    t.integer  "duration_seconds"
    t.integer  "duration_weeks"
    t.integer  "duration_years"
    t.string   "temporal_entity_type"
  end

  create_table "interactions_consumes_resources", :id => false, :force => true do |t|
    t.integer "interaction_id"
    t.integer "resource_id"
  end

  create_table "interactions_creates_resources", :id => false, :force => true do |t|
    t.integer "interaction_id"
    t.integer "resource_id"
  end

  create_table "interactions_locations", :id => false, :force => true do |t|
    t.integer "interaction_id"
    t.integer "location_id"
  end

  add_index "interactions_locations", ["interaction_id", "location_id"], :name => "index_interactions_locations_on_interaction_id_and_location_id"

  create_table "interactions_processes", :id => false, :force => true do |t|
    t.integer "interaction_id"
    t.integer "process_entity_id"
  end

  create_table "interactions_receives_resources", :id => false, :force => true do |t|
    t.integer "interaction_id"
    t.integer "resource_id"
  end

  create_table "interactions_returns_resources", :id => false, :force => true do |t|
    t.integer "interaction_id"
    t.integer "resource_id"
  end

  create_table "interactions_roles", :id => false, :force => true do |t|
    t.integer "interaction_id"
    t.integer "role_id"
  end

  add_index "interactions_roles", ["interaction_id", "role_id"], :name => "index_interactions_roles_on_interaction_id_and_role_id"

  create_table "locations", :force => true do |t|
    t.string   "sid"
    t.integer  "service_system_id"
    t.string   "label"
    t.integer  "location_id"
    t.string   "gn_feature"
    t.text     "comment"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "process_entities", :force => true do |t|
    t.string   "sid"
    t.integer  "service_system_id"
    t.string   "label"
    t.text     "comment"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "bpmn_uri"
  end

  create_table "resources", :force => true do |t|
    t.string   "sid"
    t.integer  "service_system_id"
    t.string   "label"
    t.float    "value"
    t.float    "max_value"
    t.float    "min_value"
    t.string   "unit_of_measurement"
    t.string   "resource_type"
    t.text     "comment"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "dbpedia_resource"
  end

  create_table "roles", :force => true do |t|
    t.string   "sid"
    t.integer  "service_system_id"
    t.integer  "business_entity_id"
    t.string   "label"
    t.text     "comment"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "service_systems", :force => true do |t|
    t.string   "uri"
    t.string   "prefix"
    t.integer  "user_id"
    t.string   "label"
    t.text     "comment"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "view_status"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
