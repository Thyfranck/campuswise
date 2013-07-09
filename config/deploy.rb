require "bundler/capistrano"
require "rvm/capistrano"
require "erb"
#require "delayed/recipes"
require 'capistrano/ext/multistage'

set :stages, %w(staging production)
set :default_stage, "staging"

set(:rvm_type)          { :system }
set(:user)              { 'ubuntu' }
set(:rvm_path)          { "/usr/local/rvm" }

default_run_options[:pty] = true

set :deploy_via, :remote_cache
set :repository_cache, "cached_copy"
set :rake, 'bundle exec rake'

set :scm, 'git'
set :repository, "git@github.com:maruf-freelancer/campuswise.git"
set :git_enable_submodules, 1 # if you have vendored rails
set :git_shallow_clone, 1
set :scm_verbose, true
set :repository_cache, "cached_copy"

#the user of the server which will run commands on server
ssh_options[:port] = 22
ssh_options[:username] = 'ubuntu'
ssh_options[:host_key] = 'ssh-dss'
ssh_options[:paranoid] = false
set :use_sudo, false
ssh_options[:keys] = %w(~/ssh-keys/campuswise/pSsbR2QU.pem)
ssh_options[:forward_agent] = true

after "deploy:setup", :"deploy:create_shared_directories"

after "deploy:create_symlink", :"deploy:link_shared_files"

after "deploy", "deploy:cleanup"

#If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end

  task :stop do ; end

  task :restart, :roles => :app, :except => { :no_release => true } do
    run "sudo touch #{File.join(current_path, 'tmp', 'restart.txt')}"
  end

  task :install_bundle, :roles => :app do
    run "cd #{current_path}; rvmsudo bundle install"
  end

  task :create_shared_directories, :role => :app do
    run "mkdir -p #{shared_path}/sockets"
    run "mkdir -p #{shared_path}/uploads"
    run "mkdir -p #{shared_path}/pids"
    run "mkdir -p #{shared_path}/log"
    run "mkdir -p #{shared_path}/bundle"
  end

  task :link_shared_files, :roles => :app do
    run "rm -rf #{current_path}/tmp/sockets; ln -s #{shared_path}/sockets #{current_path}/tmp/sockets"
    run "rm -rf #{current_path}/public/uploads; ln -s #{shared_path}/uploads #{current_path}/public/uploads"
  end

  task :db_seed, :roles => :app do
    run "cd #{current_path};RAILS_ENV=#{rails_env} bundle exec rake db:seed"
  end

  task :db_create, :roles => :app do
    run "cd #{current_path};RAILS_ENV=#{rails_env} bundle exec rake db:create"
  end

  namespace :delayed_job do
    desc "Stop the delayed_job process"
    task :stop, :roles => :app do
      run "cd #{current_path};RAILS_ENV=#{rails_env} #{ruby_path} script/delayed_job stop"
    end

    desc "Status of existing delayed_job process"
    task :status, :roles => :app do
      run "cd #{current_path};RAILS_ENV=#{rails_env} #{ruby_path} script/delayed_job status"
    end

    desc "Start the delayed_job process"
    task :start, :roles => :app do
      run "cd #{current_path};RAILS_ENV=#{rails_env} #{ruby_path} script/delayed_job -n 2 start"
    end

    desc "Restart the delayed_job process"
    task :restart, :roles => :app do
      run "cd #{current_path};RAILS_ENV=#{rails_env} #{ruby_path} script/delayed_job -n 2 restart"
    end

    desc "Start via rake task"
    task :start_rake, :roles => :app do
      run "cd #{current_path};RAILS_ENV=#{rails_env} bundle exec rake jobs:work"
    end
  end
end
