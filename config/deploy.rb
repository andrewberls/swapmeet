require "bundler/capistrano"

set :application, "Swapmeet"
set :repository,  "git@github.com:andrewberls/swapmeet.git"
set :scm, :git 
set :branch, "master"

set :deploy_to, "/home/ubuntu"
set :user, "ubuntu"


role :web, "swapmeet.dnsdynamic.net"                          # Your HTTP server, Apache/etc
role :app, "swapmeet.dnsdynamic.net"                          # This may be the same as your `Web` server
role :db,  "swapmeet.dnsdynamic.net", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

#Move the aws credentials from where RightScript put them to where it should be
after "deploy:update_code", "deploy:symlink_aws.yml"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
  task :symlink_aws do
    run "ln -nfs #{shared_path}/config/aws.yml #{release_path}/config/aws.yml"
  end
end


ssh_options[:keys] = ["~/.ssh/our-key-from-rightscale"]
ssh_options[:forward_agent] = true
