require 'rubygems'
require 'rufus/scheduler'
require 'parseconfig'

# Define some config parameters
$bot_config  = ParseConfig.new('cfg/bot_cfg')
$secret_key  = $bot_config.get_value('secret_key')

# Initialize rufus scheduler
$scheduler = Rufus::Scheduler.start_new

# Sinatra web
require File.expand_path('../web/server', __FILE__)

run Rack::URLMap.new \
  "/"       => Sinatra::Application
