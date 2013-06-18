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

ActiveRecord::Schema.define(:version => 20130618113017) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "admin_users", :force => true do |t|
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

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "billing_events", :force => true do |t|
    t.string   "event_type"
    t.text     "response"
    t.integer  "user_id"
    t.integer  "payment_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "billing_settings", :force => true do |t|
    t.string   "card_holder_name"
    t.string   "card_expiry_date"
    t.string   "card_last_four_digits"
    t.string   "card_type"
    t.string   "stripe_id"
    t.integer  "user_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  create_table "books", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.string   "image"
    t.string   "author"
    t.string   "isbn"
    t.string   "publisher"
    t.decimal  "purchase_price", :precision => 10, :scale => 2
    t.boolean  "available"
    t.date     "available_from"
    t.date     "returning_date"
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
    t.boolean  "requested",                                     :default => false
    t.decimal  "loan_daily",     :precision => 10, :scale => 2
    t.decimal  "loan_weekly",    :precision => 10, :scale => 2
    t.decimal  "loan_monthly",   :precision => 10, :scale => 2
    t.decimal  "loan_semester",  :precision => 10, :scale => 2
    t.decimal  "price",          :precision => 10, :scale => 2
    t.string   "available_for"
  end

  create_table "dashboard_notifications", :force => true do |t|
    t.integer  "user_id"
    t.string   "content"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.integer  "admin_user_id"
    t.integer  "withdraw_request_id"
    t.integer  "dashboardable_id"
    t.string   "dashboardable_type"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "exchanges", :force => true do |t|
    t.integer  "book_id"
    t.integer  "user_id"
    t.string   "status",                                                    :default => "0"
    t.datetime "created_at",                                                                 :null => false
    t.datetime "updated_at",                                                                 :null => false
    t.decimal  "amount",                     :precision => 10, :scale => 2
    t.string   "package"
    t.integer  "duration"
    t.datetime "starting_date"
    t.datetime "ending_date"
    t.decimal  "counter_offer",              :precision => 10, :scale => 2
    t.integer  "counter_offer_last_made_by"
    t.integer  "counter_offer_count",                                       :default => 0
  end

  create_table "payment_methods", :force => true do |t|
    t.integer  "user_id"
    t.string   "payment_method_type"
    t.string   "bank_name"
    t.string   "account_holder_name"
    t.string   "account_number"
    t.string   "credit_card_type"
    t.string   "card_number"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "bank_branch"
    t.string   "paypal"
  end

  create_table "payments", :force => true do |t|
    t.integer  "exchange_id"
    t.decimal  "payment_amount", :precision => 10, :scale => 2, :default => 0.0
    t.string   "status"
    t.string   "charge_id"
    t.datetime "created_at",                                                     :null => false
    t.datetime "updated_at",                                                     :null => false
  end

  create_table "school_images", :force => true do |t|
    t.integer  "school_id"
    t.string   "image"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "schools", :force => true do |t|
    t.string   "name"
    t.string   "email_postfix"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.date     "spring_semester"
    t.date     "fall_semester"
  end

  create_table "transactions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "transactable_id"
    t.string   "transactable_type"
    t.text     "description"
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
    t.decimal  "amount",            :precision => 10, :scale => 2
  end

  create_table "users", :force => true do |t|
    t.integer  "school_id"
    t.string   "email",                                                                                 :null => false
    t.string   "name"
    t.string   "phone"
    t.string   "facebook"
    t.string   "crypted_password"
    t.string   "salt"
    t.datetime "created_at",                                                                            :null => false
    t.datetime "updated_at",                                                                            :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.datetime "last_login_at"
    t.datetime "last_logout_at"
    t.datetime "last_activity_at"
    t.integer  "failed_logins_count",                                            :default => 0
    t.datetime "lock_expires_at"
    t.string   "unlock_token"
    t.string   "activation_state"
    t.string   "activation_token"
    t.datetime "activation_token_expires_at"
    t.string   "phone_verification"
    t.string   "phone_verified",                                                 :default => "pending"
    t.decimal  "credit",                          :precision => 10, :scale => 2
    t.decimal  "debit",                           :precision => 10, :scale => 2
  end

  add_index "users", ["activation_token"], :name => "index_users_on_activation_token"
  add_index "users", ["last_logout_at", "last_activity_at"], :name => "index_users_on_last_logout_at_and_last_activity_at"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token"

  create_table "withdraw_requests", :force => true do |t|
    t.integer  "user_id"
    t.decimal  "amount",         :precision => 10, :scale => 2
    t.string   "status"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.string   "payment_method"
  end

end
