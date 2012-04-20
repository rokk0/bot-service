# Sinatra web
require File.expand_path('../web/server', __FILE__)

# Resque web
require 'resque/server'

run Rack::URLMap.new \
  "/"       => Sinatra::Application,
  "/resque" => Resque::Server.new
