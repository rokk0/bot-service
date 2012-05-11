require 'rubygems'
require 'rufus/scheduler'
require 'parseconfig'
require 'clogger'

# Define some config parameters
$bot_config = ParseConfig.new('cfg/service_cfg')
$secret_key = $bot_config.get_value('secret_key')

# Initialize rufus scheduler
$scheduler = Rufus::Scheduler.start_new

# Initialize global variable for VK sessions
$accounts = {}

# Sinatra web
require File.expand_path('../web/server', __FILE__)

use Clogger,
    :format    => Clogger::Format::Fancy,
    :logger    => $stdout,
    :reentrant => false

run Rack::URLMap.new \
  "/" => Sinatra::Application
