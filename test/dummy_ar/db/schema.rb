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

ActiveRecord::Schema.define(:version => 20120615134758) do

  create_table "oauth2_provider_accesses", :force => true do |t|
    t.string   "client_uri"
    t.string   "resource_owner_uri"
    t.datetime "blocked"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "oauth2_provider_authorizations", :force => true do |t|
    t.string   "client_uri"
    t.string   "resource_owner_uri"
    t.string   "code"
    t.string   "scope_json"
    t.datetime "expire_at"
    t.datetime "blocked"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "oauth2_provider_clients", :force => true do |t|
    t.string   "uri"
    t.string   "name"
    t.string   "created_from"
    t.string   "secret"
    t.string   "site_uri"
    t.string   "redirect_uri"
    t.string   "scope_json"
    t.string   "scope_values_json"
    t.string   "info"
    t.integer  "granted_times",     :default => 0, :null => false
    t.integer  "revoked_times",     :default => 0, :null => false
    t.datetime "blocked"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  create_table "oauth2_provider_daily_requests", :force => true do |t|
    t.string   "time_id"
    t.integer  "day"
    t.integer  "month"
    t.integer  "year"
    t.integer  "times"
    t.integer  "oauth2_provider_access_id"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "oauth2_provider_refresh_tokens", :force => true do |t|
    t.string   "refresh_token"
    t.string   "access_token"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "oauth2_provider_scopes", :force => true do |t|
    t.string   "name"
    t.string   "uri"
    t.string   "values_json"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "oauth2_provider_tokens", :force => true do |t|
    t.string   "client_uri"
    t.string   "resource_owner_uri"
    t.string   "token"
    t.string   "refresh_token"
    t.string   "scope_json"
    t.datetime "expire_at"
    t.datetime "blocked"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                  :null => false
    t.string   "crypted_password",                       :null => false
    t.string   "password_salt",                          :null => false
    t.string   "persistence_token",                      :null => false
    t.string   "single_access_token",                    :null => false
    t.string   "perishable_token",                       :null => false
    t.boolean  "admin",               :default => false, :null => false
    t.integer  "login_count",         :default => 0,     :null => false
    t.integer  "failed_login_count",  :default => 0,     :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

end
