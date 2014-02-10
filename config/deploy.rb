require 'bundler/capistrano'     #添加之后部署时会调用bundle install， 如果不需要就可以注释掉  


set :stages, %w(development production)
set :default_stage, "development"
require "capistrano/ext/multistage"     #多stage部署所需  

set :application, "blog"   #应用名称  
set :keep_releases, 5          #只保留5个备份  

set :repository, "git@github.com:dongkai1208/blog.git"

set :deploy_to, "/var/www/cap/#{application}"  #部署到远程机器的路径  

set :user, "dk"              #登录部署机器的用户名
                                 #set :password, "doraemon"      #登录部署机器的密码， 如果不设部署时需要输入密码


default_run_options[:pty] = true          #pty: 伪登录设备  
                                 #default_run_options[:shell] = false     #Disable sh wrapping


set :use_sudo, true                            #执行的命令中含有sudo， 如果设为false， 用户所有操作都有权限  
set :runner, "user2"                          #以user2用户启动服务  
                                 #set :svn_username, "xxxx"


set :scm, :git                     #
                                 # Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
                                 #set :deploy_via, :copy                     #如果SCM设为空， 也可通过直接copy本地repo部署



                                 # set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
                                 # Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :host, "{user}@115.28.139.161"
role :web, "115.28.139.161"                          # Your HTTP server, Apache/etc
role :app, "115.28.139.161"                          # This may be the same as your `Web` server
role :db,  "115.28.139.161", :primary => true # This is where Rails migrations will run
                                 #role :db,  "your slave db-server here"
namespace :deploy do


  desc "remove and destory this app"
  task :destory, :roles => :app do
    run "cd #{deploy_to}/../ && #{try_sudo} mv #{application} /tmp/#{application}_#{Time.now.strftime('%Y%d%m%H%M%S')}"      #try_sudo 以sudo权限执行命令
  end


  after "deploy:update", "deploy:shared:setup"              #after， before 表示在特定操作之后或之前执行其他任务


  namespace :shared do
    desc "setup shared folder symblink"
    task :setup do
      run "cd #{deploy_to}/current; rm -rf shared; ln -s #{shared_path} ."
    end
  end


  after "deploy:setup", "deploy:setup_chown"
  desc "change owner from root to user1"
  task :setup_chown do
    run "cd #{deploy_to}/../ && #{try_sudo} chown -R #{user}:#{user} #{application}"
  end



  task :start do
    run "cd #{deploy_to}/current && ./crmd.sh start"
    #try_sudo "cd #{deploy_to}/current && ./restart.sh"
  end


  task :stop do
    run "cd #{deploy_to}/current && ./crmd.sh stop"
  end


  task :restart do
    run "cd #{deploy_to}/current && ./crmd.sh restart"
  end

end
# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
