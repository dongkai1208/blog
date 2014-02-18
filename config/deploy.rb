require 'bundler/capistrano'    #it will execute 'bundle install' when deploy



# Load RVM's capistrano plugin.    
require "rvm/capistrano"

set :stages, %w(development production)
set :default_stage, "development"
require "capistrano/ext/multistage"     #used for multi-stage deploy

set :application, "blog"   #the name of application
set :keep_releases, 5          #keep 5 backups


set :deploy_to, "/var/www/cap/#{application}"  #the path of remote server
set :user, "dk"              #the user name of deploy server
set :password, "doraemon"      #the password of deploy server


default_run_options[:pty] = true      #default_run_options[:shell] = false  #Disable sh wrapping
set :ssh_options, { :forward_agent => true }

set :use_sudo, true                            #if false， user does not have permission to operate
set :runner, "user2"                          #use user2 to start
                                 #set :svn_username, "xxxx"


set :repository, "git@github.com:dongkai1208/blog.git"  # Your clone URL
set :scm, "git"



set :branch, "master"

role :web, "115.28.139.161"                          # Your HTTP server, Apache/etc
role :app, "115.28.139.161"                          # This may be the same as your `Web` server
role :db,  "115.28.139.161", :primary => true # This is where Rails migrations will run
                                 #role :db,  "your slave db-server here"
namespace :deploy do


  desc "remove and destory this app"
  task :destory, :roles => :app do
    run "cd #{deploy_to}/../ && #{try_sudo} mv #{application} /tmp/#{application}_#{Time.now.strftime('%Y%d%m%H%M%S')}"      #try_sudo 以sudo权限执行命令
  end


  after "deploy:update", "deploy:shared:setup"


  namespace :shared do
    desc "setup shared folder symblink"
    task :setup do
      run "cd #{deploy_to}; rm -rf shared; ln -s #{shared_path} ."
    end
  end


  after "deploy:setup", "deploy:setup_chown"
  desc "change owner from root to user1"
  task :setup_chown do
    run "cd #{deploy_to}/../ && #{try_sudo} chown -R #{user}:#{user} #{application}"
  end



  task :start do
    run "cd #{deploy_to} && ./crmd.sh start"
    #try_sudo "cd #{deploy_to} && ./restart.sh"
  end


  task :stop do
    run "cd #{deploy_to} && ./crmd.sh stop"
  end


  task :restart do
    run "cd #{deploy_to} && ./crmd.sh restart"
  end

end

