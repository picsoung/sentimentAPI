require "bundler/capistrano"


set :application, "grapeapi"
set :user,"azureuser"
#set :group, "staff"

set :scm, :git
set :repository, "git@github.com:picsoung/private.sentimentAPI.git"
set :branch, "master"
set :use_sudo, false


server "az3scale.cloudapp.net", :web, :app, :db, primary: true


set :deploy_to, "/home/#{user}/apps/#{application}"
default_run_options[:pty] = true

ssh_options[:forward_agent] = true
ssh_options[:port] = 22
ssh_options[:keys] = ["/Users/picsoung/Documents/Dev/3scale/add-on/azure_grape_openresty/myPrivateKey.key"]


namespace :deploy do
  task :start, :roles => [:web, :app] do
    run "cd #{deploy_to}/current && nohup bundle exec thin start -C config/production_config.yml -R config.ru"
    sudo "/opt/openresty/nginx/sbin/nginx -p /opt/openresty/nginx/ -c /opt/openresty/nginx/conf/nginx.conf"
  end
 
  task :stop, :roles => [:web, :app] do
    #sudo "/opt/openresty/nginx/sbin/nginx -s stop"
    sudo "kill -QUIT $(cat /opt/openresty/nginx/logs/nginx.pid)"
    run "cd #{deploy_to}/current && nohup bundle exec thin stop -C config/production_config.yml -R config.ru"
  end
 
  task :restart, :roles => [:web, :app] do
    deploy.stop
    deploy.start
  end

  task :setup_config, roles: :app do
    # sudo "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
    sudo "ln -nfs #{current_path}/config/nginx.conf /opt/openresty/nginx/conf/nginx.conf"
    sudo "ln -nfs #{current_path}/config/lua_tmp.lua /opt/openresty/nginx/conf/lua_tmp.lua"
    sudo "mkdir -p #{shared_path}/config"
  end
  after "deploy:setup", "deploy:setup_config"
 
  # This will make sure that Capistrano doesn't try to run rake:migrate (this is not a Rails project!)
  task :cold do
    deploy.update
    deploy.start
  end
end