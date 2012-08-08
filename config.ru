require 'rubygems'
require 'rufus/scheduler'
require 'yaml'
require 'clogger'

# Define some config parameters
$bot_config = YAML.load(File.read("config/service.yml"))
$secret_key = $bot_config['secret_key']

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

run Sinatra::Application
