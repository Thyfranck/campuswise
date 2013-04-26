set(:ruby_version)      { '1.9.3-p286' }
set(:rvm_ruby_string)   { "1.9.3-p286" }

set :application, "ec2-54-225-97-117.compute-1.amazonaws.com"
set :deploy_to, "/vol/apps/campuswise-staging"
set :rails_env, "staging"
set :ruby_path, "/usr/local/rvm/rubies/ruby-1.9.3-p286/bin/ruby"
set :branch, 'staging'

role :web, "ec2-54-225-97-117.compute-1.amazonaws.com" # Your HTTP server, Apache/etc
role :app, "ec2-54-225-97-117.compute-1.amazonaws.com" # This may be the same as your `Web` server
role :db, "ec2-54-225-97-117.compute-1.amazonaws.com", :primary => true # This is where Rails migrations will run
role :db, "ec2-54-225-97-117.compute-1.amazonaws.com"
