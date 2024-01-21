# frozen_string_literal: true

require 'mina/multistage'
require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
# require 'mina/rbenv'  # for rbenv support. (https://rbenv.org)
require 'mina/rvm'    # for rvm support. (https://rvm.io)

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)


set :rvm_use_path, '/usr/share/rvm/bin/rvm'
# Optional settings:
set :user, 'deployer'          # Username in the server to SSH to.
#   set :port, '30000'           # SSH port number.
set :forward_agent, true     # SSH forward_agent.

# Optional settings:
#   set :user, 'foobar'          # Username in the server to SSH to.
#   set :port, '30000'           # SSH port number.
#   set :forward_agent, true     # SSH forward_agent.

# Shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
# Some plugins already add folders to shared_dirs like `mina/rails` add `public/assets`, `vendor/bundle` and many more
# run `mina -d` to see all folders and files already included in `shared_dirs` and `shared_files`
# set :shared_dirs, fetch(:shared_dirs, []).push('public/assets')
# set :shared_files, fetch(:shared_files, []).push('config/database.yml', 'config/secrets.yml')
set :shared_files, fetch(:shared_files, []).push('config/master.key', 'config/credentials/production.key', 'config/puma.rb', '.ruby-version', 'config/database.yml')

# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
task :remote_environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  # invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  invoke :'rvm:use', 'ruby-3.2.2@default'
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task setup: :remote_environment do
  # command %{rbenv install 3.0.5 --skip-existing}
  command %{rvm install ruby-3.2.2}
  command %{gem install bundler}
  command %[touch "#{fetch(:shared_path)}/config/master.key"]
  command %[touch "#{fetch(:shared_path)}/config/puma.rb"]
  command %[touch "#{fetch(:shared_path)}/config/credentials/production.key"]
  # command %[touch "#{fetch(:shared_path)}/config/database.yml"]
  command %[mkdir -p "#{fetch(:shared_path)}/public/assets"]
  command %[mkdir -p "#{fetch(:shared_path)}/log"]
  command %[mkdir -p "#{fetch(:shared_path)}/tmp/cache"]
  command %[mkdir -p "#{fetch(:shared_path)}/tmp/sockets"]
end

desc 'Deploys the current version to the server.'
task deploy: :remote_environment do
  # uncomment this line to make sure you pushed your local branch to the remote origin
  # invoke :'git:ensure_pushed'
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    # invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    # TODO: DEPLOY PUMA WITH SYSTEMCTL
    on :launch do
      command %{sudo /usr/bin/rm /etc/nginx/sites-enabled/meeanw-telegram.conf}
      command %{sudo /usr/bin/ln -s /var/www/meeanw-telegram-bot/current/config/deploy/meeanw-telegram.conf /etc/nginx/sites-enabled/meeanw-telegram.conf}
      command %{sudo /usr/sbin/service nginx restart}
      command %{sudo /usr/sbin/service meeanw-telegram-puma restart}
    end
  end
end

# For help in making your deploy script, see the Mina documentation:
#
#  - https://github.com/mina-deploy/mina/tree/master/docs
