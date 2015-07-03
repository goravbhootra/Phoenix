require './config/boot'
require 'airbrake/capistrano3'

lock '3.4.0'

# application name
set :application, "phoenix"
set :repo_url, "gitpvt@git.gorav.in:gorav/phoenix.git"
# set :user, "gitpvt"

# ssh_options[:port] = 1222

set :ssh_options, { forward_agent: true } #, port: 1222 }
# set :ssh_options, {
#   forward_agent: true,
#   port: 1222
# }

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, '/var/www/my_app'

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{ config/database.yml config/secrets.yml } #config/initializers/airbrake.rb }

# Default value for linked_dirs is []
set :linked_dirs, %w{ log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system tmp/pdf }
set :bundle_binstubs, nil

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :default_env, {
    rvm_bin_path: '/usr/local/rvm/bin',
    path: '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin',
}

# Default value for keep_releases is 5
set :keep_releases, 15

namespace :deploy do
    # after 'deploy:finished', 'airbrake:deploy'

  set :bundle_without, %w{development test}.join(' ')
  set :bundle_roles, :all
  namespace :bundler do
    desc "Install gems with bundler."
    task :install do
      on roles fetch(:bundle_roles) do
        within release_path do
          execute :bundle, "install", "--without #{fetch(:bundle_without)}"
        end
      end
    end
  end
  # before 'deploy:updated', 'bundler:install'

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  # after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
end
