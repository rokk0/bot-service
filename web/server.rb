#!/usr/bin/env ruby
# File: server.rb

require 'sinatra'
require 'json'
require 'encryptor'

# Our main code is there
require_relative '../lib/app'

# Settings
set :views, File.dirname(__FILE__) + '/views'
set :public_folder, File.dirname(__FILE__) + '/assets'
set :erb, :layout => :'layouts/default'
set :show_exceptions, false

# Hooks
before '/api/*' do
  content_type 'application/json'
end

# Routes
# => Root
get '/' do
  erb :index
end

get '/api' do
  { :status => :ok, :message => 'oh hai there' }
end

# => Routes for /api/bot
require_relative 'routes/bot'

not_found do
  { :status => :failed, :message => 'not found' }.to_json
end

error 400..510 do
  { :status => :failed, :message => request.env['sinatra.error'].message }
end
