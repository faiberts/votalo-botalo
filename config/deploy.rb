require "bundler/capistrano"
require "rvm/capistrano"

set :application, "votalo-botalo"
set :deploy_to, "/home/vob/#{application}"

require "capistrano-unicorn"

set :user, "vob"
set :domain, "67.202.108.133"
set :environment, "production"

role :app, domain
role :web, domain
role :db, domain, :primary => true

set :normalize_asset_timestamps, false
set :rvm_ruby_string, '1.9.3-p327'
set :rvm_type, :user

set :scm, :git
set :repository, "git://github.com/munshkr/votalo-botalo.git"
set :branch, "master"
set :scm_verbose, true
set :use_sudo, false
set :ssh_options, :forward_agent => true

set :keep_releases, 5

set :config_files, %w{ }

namespace :deploy do
  desc "Create symlinks to shared files"
  task :create_symlink_shared do
    config_files.each do |filename|
      run "ln -nfs #{deploy_to}/shared/config/#{filename}.yml #{release_path}/config/#{filename}.yml"
    end
    run "ln -nfs #{deploy_to}/shared/db/votalo.db #{release_path}/db/votalo.db"
    run "ln -nfs #{deploy_to}/shared/pids #{release_path}/tmp"
  end
end

after "deploy:update_code", "deploy:create_symlink_shared"

after "deploy:start",   "unicorn:start"
after "deploy:stop",    "unicorn:stop"
after "deploy:restart", "unicorn:reload"


def rake(task)
  run "cd #{current_path} && APP_ENV=production bundle exec rake #{task} --trace"
end
