load 'deploy' if respond_to?(:namespace) # cap2 differentiator

set :user, 'madundead'
set :domain, '50.19.253.28'

server "#{user}@#{domain}", :staging

ssh_options[:keys] = ["#{ENV['HOME']}/Dropbox/Amazon/madundead-ruby-stag.pem"]

default_run_options[:pty] = true

# the rest should be good
set :repository,  "git@github.com:rokk0/bot-service.git"
set :deploy_to, "/home/madundead/bot-service"
set :deploy_via, :remote_cache
set :scm, 'git'
set :branch, 'capistrano'
set :git_shallow_clone, 1
set :scm_verbose, true
set :use_sudo, false
