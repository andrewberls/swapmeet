require "bundler/capistrano"

# Use -s branch=BRANCHNAME to change branches

# Use git read-only to avoid SSH key issues
set :repository, "git://github.com/andrewberls/swapmeet.git"
set :scm, :git
set :branch, "master"

set :deploy_to, "/home/ubuntu"
set :user, "ubuntu"
set :use_sudo, false

role :web, "swapmeetapp1.dnsdynamic.net", "swapmeetapp2.dnsdynamic.net"    # Your HTTP server, Apache/etc
role :app, "swapmeetapp1.dnsdynamic.net", "swapmeetapp2.dnsdynamic.net"    # This may be the same as your `Web` server
role :db,  "swapmeetapp1.dnsdynamic.net", :primary => true                 # This is where Rails migrations will run

# Move the AWS credentials from where RightScript put them to where it should be
after "deploy:update_code", "deploy:symlink_aws"

# Migrate
after "deploy:update_code", "deploy:migrate"

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

namespace :db do
  task :seed, :only => { :primary => true } do
    run "cd #{current_path}; bundle exec rake db:seed RAILS_ENV=#{rails_env}"
  end
end

ssh_options[:keys] = ["~/.ssh/our-key-from-rightscale"]
ssh_options[:forward_agent] = true
